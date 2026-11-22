# PXE Tools configuration template

[Version française](README.fr.md)

Starting point for the Git repository that holds your PXE Tools Ansible
playbooks and exported presets. Click **Use this template**, create a
**private** repository, then connect it to PXE Tools.

## What goes where

| In this repository (Git) | In the PXE Tools database |
| --- | --- |
| Playbooks, roles, inventory, variables | Machines, accounts, settings, jobs |
| Presets exported with **Save to GitHub** | Presets in use (the database is authoritative) |
| Vault-encrypted values only | Secrets, encrypted with the instance master key |

Git backs up the *recipe*. Back up the database separately with the PXE Tools
recovery archive.

## Layout

```text
pxe-tools.json            Profile manifest read by PXE Tools
playbooks/<role>.yml      One entry point per PXE Tools role
roles/                    Roles used by the playbooks
inventory/hosts.yml       Your machines, named as in PXE Tools
inventory/group_vars/     Shared variables
presets/                  Presets written by "Save to GitHub"
ansible.cfg               Local settings matching the PXE Tools worker
```

`pxe-tools.json` lists the files PXE Tools fetches (`paths`) and the playbook of
each role (`playbooks`). A file outside `paths` is not fetched. The template
ships one role, `base`: packages, timezone, NTP (chrony) and automatic
security updates on Debian or Ubuntu.

## Connect it to PXE Tools

1. Create your repository from this template, as **private**.
2. Add a read-only **deploy key** to it (repository **Settings → Deploy keys**).
   Give the private key to the PXE Tools worker through `PXE_GIT_SSH_KEY`, and
   add GitHub's verified host keys to the worker's `known_hosts`: unknown
   hosts are refused. The web interface has no field for this key yet.
3. In PXE Tools, open **Settings → Ansible**, enable Ansible, then set:
   - repository URL: `git@github.com:<you>/<repository>.git`
   - branch: `main`
   - profile manifest: `pxe-tools.json`
4. Restart the worker: the first clone happens when it starts.
5. In a preset, set the role to `base` under *Automation after installation*.
6. Add the machine to `inventory/hosts.yml` under the **same name** as in PXE
   Tools, commit and push.

## Add a role

1. Write `playbooks/<role>.yml` and its role under `roles/`.
2. Add both paths to `paths` and the mapping to `playbooks` in
   `pxe-tools.json`.
3. Push: the **Check** workflow validates the manifest with the PXE Tools
   validator, then runs a syntax check and `ansible-lint`.

Check locally with `bash scripts/check-profile.sh` (it reads the committed
`HEAD`, as the server does).

## Current limits

- PXE Tools does not generate the inventory: declare each machine twice, in
  PXE Tools and in `inventory/hosts.yml`.
- PXE Tools does not install `requirements.yml`. Use `ansible.builtin` modules,
  or collections already installed on the PXE Tools server.
- The worker checks SSH host keys; an unknown host key stops the run.
- **Save to GitHub** pushes with a personal access token, because the deploy
  key is read-only.

## Licence

[MIT-0](LICENSE): copy and adapt it freely, without attribution.
