# JOKO Terminal Pro (No Panel)

Versi ini jalan full dari terminal VPS:
- tanpa panel web
- tanpa Cloudflare tunnel
- menu warna
- auto refresh live tiap 2 detik
- shortcut keyboard tanpa Enter
- status CPU / RAM / Disk / proses tampil langsung saat container jalan

## File yang harus ada di folder ini
- Dockerfile
- entrypoint.sh
- terminal_menu.sh
- run_terminal.sh
- login.py
- loop.py
- buat_link.py

## Cara run sampai berhasil

### 1) Install Docker di VPS Ubuntu
```bash
sudo apt update
sudo apt install -y docker.io
sudo systemctl enable docker
sudo systemctl start docker
sudo usermod -aG docker $USER
```
Lalu logout lalu login lagi ke VPS.

### 2) Masuk ke folder project
```bash
cd /path/ke/folder/joko_terminal_pro
```

### 3) Pastikan file script utama sudah ada
```bash
ls -lah
```
Minimal harus ada:
- `login.py`
- `loop.py`
- `buat_link.py`

### 4) Jalankan
```bash
chmod +x run_terminal.sh
./run_terminal.sh
```

Kalau berhasil, terminal langsung tampil menu interaktif.

## Shortcut keyboard
- `1` Start Login
- `2` Stop Login
- `3` Start Loop
- `4` Stop Loop
- `5` Start Buat Link
- `6` Stop Buat Link
- `7` Stop ALL
- `8` Kill ALL
- `c` Clear RAM Cache
- `m` Reset Mapping
- `r` Reset Chrome Profiles
- `p` Delete Chrome Profiles
- `g` Cleanup root PNG
- `l` Cleanup log/json/lock
- `v` View logs
- `s` View screenshots
- `h` Help
- `q` Quit

## Cara run manual tanpa script helper
```bash
docker build -t joko-terminal-pro .
docker run --rm -it --privileged --name joko-terminal -v $(pwd)/data:/joko-app/data joko-terminal-pro
```

## Kalau menu tidak muncul
Pastikan run pakai `-it`.

## Kalau clear RAM cache gagal
Fitur itu butuh `--privileged` atau permission root dalam container.

## Cara buka lagi setelah keluar
Tinggal jalankan lagi:
```bash
./run_terminal.sh
```

cek loop
docker exec -it joko-terminal-data-v5 pgrep -af loop.py

stop loop manual
bash start_loop_inside_docker.sh
