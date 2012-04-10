rem
rem bochsrc-gen.bat
rem
rem generates a .bochsrc file for a frosk image
rem not tested
rem
rem written by sjrct
rem

set image=frosk.img
set output=.bochsrc
set hpc=16
set spt=63

for /f "usebackq" %%a in ('%image%') do set imgsize=%%~zA
set /a cyl=(%imgsize% / 512) / (%spt% * %hpc%)
set /a remain=%imgsize% % (%spt% * %hpc% * 512)

if [not] %remain%==0 set cyl=$((%cyl%+1))

echo "ata0: enabled=1, ioaddr1=0x1f0, ioaddr2=0x3f0, irq=14" > $output
echo "ata0-master: type=disk, path=\"%image%\", mode=flat, cylinders=%cyl%, heads=%hpc%, spt=%spt%, translation=lba" >> %output%
echo "config_interface: wx" >> %output%
echo "display_library: wx" >> %output%
echo "boot: disk" >> %output%
echo "log: log.txt" >> %output%

