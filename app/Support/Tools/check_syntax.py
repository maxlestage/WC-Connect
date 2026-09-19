#!/usr/bin/env python3
"""Contrôle structurel léger des sources Swift.

**Ce n'est pas un compilateur.** Aucun toolchain Swift n'est disponible dans
l'environnement de développement : la seule vérification réelle du code Swift
est la CI macOS. Ce script attrape la classe d'erreur la plus bête et la plus
coûteuse — celle qui casse la construction pour une virgule — avant de
consommer un tour de runner macOS, facturé dix fois le tarif Linux.

Il vérifie, hors chaînes et commentaires :
  * l'équilibre des parenthèses, accolades et crochets, fichier par fichier ;
  * la séparation des éléments d'un tableau littéral multiligne : chaque
    élément doit être suivi d'une virgule, sauf le dernier.

Le second point vient d'une erreur réelle : un élément ajouté à `TipLibrary.all`
sans virgule après le précédent, qui a fait échouer la construction.

Usage : python3 app/Support/Tools/check_syntax.py
"""
import pathlib
import re
import sys

PAIRES = [("(", ")"), ("{", "}"), ("[", "]")]


def sans_texte(source: str) -> str:
    """Source privée de ses chaînes et commentaires, pour ne compter que la
    structure. Les chaînes multilignes passent en premier."""
    source = re.sub(r'"""(?:.|\n)*?"""', '""', source)
    source = re.sub(r'"(?:[^"\\\n]|\\.)*"', '""', source)
    source = re.sub(r"/\*(?:.|\n)*?\*/", "", source)
    source = re.sub(r"//[^\n]*", "", source)
    return source


def equilibre(chemin: pathlib.Path, nu: str) -> list[str]:
    erreurs = []
    for ouvrant, fermant in PAIRES:
        a, b = nu.count(ouvrant), nu.count(fermant)
        if a != b:
            erreurs.append(f"{chemin} : {a} « {ouvrant} » pour {b} « {fermant} »")
    return erreurs


def virgules_de_tableau(chemin: pathlib.Path, source: str) -> list[str]:
    """Éléments d'un tableau littéral multiligne : virgule obligatoire sauf au
    dernier. On ne regarde que les éléments ouverts par un appel du type
    `Nom(` en début de ligne, seul cas présent dans ce dépôt."""
    erreurs = []
    for tableau in re.finditer(r"=\s*\[\n(.*?)\n(\s*)\]", source, re.S):
        corps = tableau.group(1)
        indentation = tableau.group(2) + "    "
        ouvertures = re.findall(rf"^{indentation}\w+\(\s*$", corps, re.M)
        if len(ouvertures) < 2:
            continue
        fermetures = re.findall(rf"^{indentation}\),?\s*$", corps, re.M)
        if len(fermetures) != len(ouvertures):
            erreurs.append(
                f"{chemin} : {len(ouvertures)} élément(s) ouvert(s) pour "
                f"{len(fermetures)} fermé(s) dans un tableau"
            )
            continue
        manquantes = [f for f in fermetures[:-1] if not f.rstrip().endswith(",")]
        if manquantes:
            erreurs.append(
                f"{chemin} : {len(manquantes)} élément(s) de tableau sans virgule "
                f"de séparation — la construction échouera"
            )
    return erreurs


def main() -> int:
    racine = pathlib.Path(__file__).resolve().parents[2]
    # Les tests aussi : une virgule oubliée dans un tableau de test coûte le
    # même quart d'heure de CI macOS qu'une virgule oubliée dans le code.
    fichiers = sorted(
        chemin
        for dossier in ("Sources", "Tests")
        for chemin in (racine / dossier).rglob("*.swift")
    )
    erreurs: list[str] = []

    for chemin in fichiers:
        source = chemin.read_text()
        relatif = chemin.relative_to(racine)
        nu = sans_texte(source)
        erreurs += equilibre(relatif, nu)
        erreurs += virgules_de_tableau(relatif, source)

    for e in erreurs:
        print(f"ÉCHEC {e}")

    if erreurs:
        print(f"\n{len(erreurs)} anomalie(s) structurelle(s).")
        return 1

    print(f"{len(fichiers)} fichiers Swift : structure cohérente.")
    print("Rappel : ce contrôle n'est pas un compilateur. Seule la CI macOS l'est.")
    return 0


if __name__ == "__main__":
    sys.exit(main())
