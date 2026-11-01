# Project-R OS — Próxima Run

**Data:** 2026-11-01  
**Objetivo:** Corrigir boot do ISO e validar emuladores

---

## Contexto

ISO foi buildada com sucesso (2679 MB, 930 pacotes, todos emuladores presentes). Porém não boota: initramfs não consegue montar o squashfs live porque o hook `archiso` está ausente do `mkinitcpio.conf`.

**Root cause:** mkarchiso não sobrescreve o preset `default` do kernel `linux-cachyos`, então mkinitcpio usa `/etc/mkinitcpio.conf` padrão sem hook `archiso` → "Failed to start Switch Root" no boot.

**Fix já aplicado no fonte:** `airootfs/etc/mkinitcpio.conf` criado com:
```
HOOKS=(base udev memdisk archiso archiso_loop_mnt)
```

---

## Passo 1 — Rebuild ISO (~20-30 min)

Usar volume mount para evitar rebuild do Docker image (pacotes já compilados):

```powershell
docker run --privileged --rm `
  -v "C:/Users/dejot/AppData/Local/Temp/project-r-os-dev/airootfs:/project-r-os/airootfs" `
  -v "C:/Users/dejot/AppData/Local/Temp/project-r-os-dev/out:/project-r-os/out" `
  project-r-builder bash docker-build.sh > "C:\Users\dejot\AppData\Local\Temp\iso-fix3.log" 2>&1
```

Monitorar:
```powershell
Get-Content "C:\Users\dejot\AppData\Local\Temp\iso-fix3.log" -Tail 10 -Wait
```

Confirmar sucesso:
```powershell
Select-String "C:\Users\dejot\AppData\Local\Temp\iso-fix3.log" -Pattern "ISO built|archiso|HOOKS"
```

**Esperado no log:** `HOOKS=(base udev memdisk archiso archiso_loop_mnt)` — confirma que o hook foi incluído no initramfs.

---

## Passo 2 — Testar ISO no QEMU

```powershell
& "C:\Program Files\qemu\qemu-system-x86_64.exe" `
  -m 4G `
  -cdrom "C:\Users\dejot\AppData\Local\Temp\project-r-os-dev\out\project-r-2026.11.01-x86_64.iso" `
  -boot d -accel tcg -cpu qemu64 -smp 2 -vga virtio -display gtk -nic user
```

**Resultado esperado:** Boot até ES-DE (EmulationStation) com auto-login do usuário `arcade`.

---

## Passo 3 — Se boot ainda falhar

**Variante A:** `archiso_loop_mnt` pode não existir em versões modernas. Testar com:
```
HOOKS=(base udev memdisk archiso)
```
Editar `airootfs/etc/mkinitcpio.conf`, repetir Passo 1.

**Variante B:** Inspecionar initramfs gerado para confirmar quais hooks estão presentes:
```bash
# Dentro do container ou após extrair ISO:
lsinitcpio /boot/initramfs-linux-cachyos.img | grep archiso
```

**Variante C:** Verificar se hooks archiso existem no chroot durante build — adicionar ao `docker-build.sh` antes de mkarchiso:
```bash
ls /usr/lib/initcpio/hooks/archiso* 2>/dev/null || echo "ARCHISO HOOKS MISSING"
```

---

## Passo 4 — Validação pós-boot

Se boot funcionar, verificar:
- [ ] ES-DE abre em fullscreen
- [ ] Usuário `arcade` logado automaticamente (sem senha)
- [ ] `/usr/bin/rpcs3`, `/usr/bin/shadps4`, `/usr/bin/duckstation`, `/usr/bin/xemu`, `/usr/bin/pcsx2` executáveis
- [ ] Audio funciona (pipewire)
- [ ] NetworkManager ativo

---

## Referências

- Docker image: `project-r-builder` (não rebuild — já tem pacotes compilados)
- QEMU: `C:\Program Files\qemu\qemu-system-x86_64.exe`
- Projeto: `C:\Users\dejot\AppData\Local\Temp\project-r-os-dev\`
- ISO output: `C:\Users\dejot\AppData\Local\Temp\project-r-os-dev\out\`
- Log anterior (referência): `C:\Users\dejot\AppData\Local\Temp\iso-fix2.log`
