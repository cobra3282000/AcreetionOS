dconf load /org/cinnamon/ < /cinnamon.dconf
dconf load /org/gnome/terminal/ < /terminal-settings

rm $HOME/.config/autostart/dd.desktop
cp /cinnamon-configs/.bashrc /root

