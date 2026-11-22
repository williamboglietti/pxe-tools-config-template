# Modèle de configuration PXE Tools

[English version](README.md)

Point de départ du dépôt Git qui contient vos playbooks Ansible et vos modèles
(presets) PXE Tools exportés. Cliquez sur **Use this template**, créez un dépôt
**privé**, puis branchez-le à PXE Tools.

## Ce qui va où

| Dans ce dépôt (Git) | Dans la base de PXE Tools |
| --- | --- |
| Playbooks, rôles, inventaire, variables | Machines, comptes, réglages, jobs |
| Modèles exportés par **Sauvegarder sur GitHub** | Modèles en service (la base fait foi) |
| Uniquement des valeurs chiffrées par Vault | Secrets, chiffrés par la clé maîtresse de l'instance |

Git sauvegarde la *recette*. Sauvegardez la base à part, avec l'archive de
récupération de PXE Tools.

## Organisation

```text
pxe-tools.json            Manifeste du profil lu par PXE Tools
playbooks/<rôle>.yml      Un point d'entrée par rôle PXE Tools
roles/                    Rôles utilisés par les playbooks
inventory/hosts.yml       Vos machines, nommées comme dans PXE Tools
inventory/group_vars/     Variables communes
presets/                  Modèles écrits par « Sauvegarder sur GitHub »
ansible.cfg               Réglages locaux alignés sur le worker PXE Tools
```

`pxe-tools.json` liste les fichiers que PXE Tools récupère (`paths`) et le
playbook de chaque rôle (`playbooks`). Un fichier hors de `paths` n'est pas
récupéré. Le modèle fournit un rôle, `base` : paquets, fuseau horaire, NTP
(chrony) et mises à jour de sécurité automatiques sur Debian ou Ubuntu.

## Brancher le dépôt à PXE Tools

1. Créez votre dépôt depuis ce modèle, en **privé**.
2. Ajoutez-y une **deploy key** en lecture seule (**Settings → Deploy keys** du
   dépôt). Donnez la clé privée au worker PXE Tools par `PXE_GIT_SSH_KEY`, et
   ajoutez les clés d'hôte vérifiées de GitHub au `known_hosts` du worker : les
   hôtes inconnus sont refusés. L'interface web n'a pas encore de champ pour
   cette clé.
3. Dans PXE Tools, ouvrez **Paramètres → Ansible**, activez Ansible, puis
   renseignez :
   - URL du dépôt : `git@github.com:<vous>/<dépôt>.git`
   - branche : `main`
   - manifeste du profil : `pxe-tools.json`
4. Redémarrez le worker : le premier clonage a lieu à son démarrage.
5. Dans un modèle, choisissez le rôle `base` sous *Automatisation après
   installation*.
6. Ajoutez la machine dans `inventory/hosts.yml` sous **le même nom** que dans
   PXE Tools, committez et poussez.

## Ajouter un rôle

1. Écrivez `playbooks/<rôle>.yml` et son rôle sous `roles/`.
2. Ajoutez les deux chemins à `paths` et l'association à `playbooks` dans
   `pxe-tools.json`.
3. Poussez : le workflow **Check** valide le manifeste avec le validateur de
   PXE Tools, puis lance un contrôle de syntaxe et `ansible-lint`.

En local : `bash scripts/check-profile.sh` (il lit le `HEAD` committé, comme le
serveur).

Le workflow tourne sur `ubuntu-24.04`. Sur un dépôt privé sans minutes de
runners hébergés, définissez la variable de dépôt `RUNNER` avec l'étiquette de
votre propre runner.

## Limites actuelles

- PXE Tools ne génère pas l'inventaire : déclarez chaque machine deux fois,
  dans PXE Tools et dans `inventory/hosts.yml`.
- PXE Tools n'installe pas `requirements.yml`. Utilisez les modules
  `ansible.builtin`, ou des collections déjà installées sur le serveur.
- Le worker vérifie les clés d'hôte SSH : une clé inconnue arrête l'exécution.
- **Sauvegarder sur GitHub** pousse avec un jeton personnel, car la deploy key
  est en lecture seule.

## Licence

[MIT-0](LICENSE) : copiez et adaptez librement, sans obligation d'attribution.
