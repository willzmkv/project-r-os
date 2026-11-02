# Project-R — Próxima Run

**Atualizado:** 2026-11-02 (sessão pausada pelo usuário)
**Plano de ondas:** `D:\Project-R\docs\superpowers\plans\2026-11-02-execution-sequence.md`
**Issues entre serviços:** `D:\Project-R\docs\superpowers\plans\2026-11-02-integration-issues.md`

## Onde paramos

- ISO `project-r-2026.11.02` **boota** no QEMU (initramfs archiso OK). Patch ao vivo do `.xinitrc` confirmou ES-DE fullscreen com autologin `arcade`.
- Fixes de sessão/pacotes estão em `main` (beb6198), **ainda sem rebuild**: `es-de`, `~/ES-DE/settings/es_settings.xml`, `systemd.firstboot=off`, hostname/locale, `lib32-vulkan-*`.
- Repo canônico agora: `D:\Project-R\repos\project-r-os` (o de `%TEMP%\project-r-os-dev` só guarda ISOs antigos em `out/`).

## Retomar (ordem)

1. **Terminar trabalho interrompido** (todos em branches no GitHub):
   - Desktop Mode — `project-r-os` branch `feat/desktop-mode`: tasks 7–14 do plano `2026-11-01-desktop-mode.md` (último commit é WIP da task 7).
   - pr-achieve — branch `wip/2026-11-02-overlay-window`: tasks 8–11.
   - decomp-registry — branch `wip/2026-11-02`: converter para schema do pr-builder, hashes verificados, validator + testes.
   - pr-theme — branch `wip/2026-11-02`: definir mecanismo de badge suportado pelo ES-DE 3.x e contrato para pr-meta.
2. **Tags faltando:** pr-meta e pr-maestro (`v0.1.0` após revisão), pr-builder `v0.1.1` (socket pr-meta).
3. **Onda 4 — integração no ISO:**
   - Trocar stubs `project-r-repo/pr-*/PKGBUILD` por PKGBUILDs reais (tags GitHub); pr-mediad já tem PKGBUILD próprio.
   - Buildar `pr-*` + `project-r-desktop-mode` em `docker-build.sh` (não na camada da imagem — evita recompilar AUR pesado).
   - Montar repo read-only no container; `work/` fica dentro do container (NTFS quebra chroot).
   - Rebuild ISO → QEMU: autologin, ES-DE, `systemctl status pr-*`.

## Comandos úteis

Rebuild (enquanto docker-build.sh não for reescrito):
```powershell
$d='D:/Project-R/repos/project-r-os'
docker run --privileged --rm -v "$d/airootfs:/project-r-os/airootfs" -v "$d/packages.x86_64:/project-r-os/packages.x86_64" -v "$d/syslinux:/project-r-os/syslinux" -v "$d/grub:/project-r-os/grub" -v "$d/efiboot:/project-r-os/efiboot" -v "$d/out:/project-r-os/out" project-r-builder bash docker-build.sh *> "$d/out/build.log"
```

Verificar ISO sem Docker: `Mount-DiskImage` + comparar SHA512 de `arch/x86_64/airootfs.sfs` com `airootfs.sha512`.

Boot QEMU sem janela (screenshots/teclas: `D:\Project-R\tools\qemu\qmon.ps1`, `qtype.ps1`):
```powershell
& "C:\Program Files\qemu\qemu-system-x86_64.exe" -m 4G -smp 4 -accel whpx,kernel-irqchip=off -accel tcg -cdrom <iso> -boot d -vga virtio -display none -nic user -monitor tcp:127.0.0.1:4444,server,nowait
```

## Cuidados

- Docker Desktop 29.9.2 crashou 3x (`com.docker.backend.exe` 0xc0000005) com I/O pesado + vários agentes. No máximo 2–3 agentes com Docker em paralelo; relançar com `"$env:LOCALAPPDATA\Programs\DockerDesktop\Docker Desktop.exe"`.
- Maestro MCP registrado (`claude mcp add -s user maestro-mcp`), mas o handshake deu timeout. Checar `claude mcp get maestro-mcp` após restart.
