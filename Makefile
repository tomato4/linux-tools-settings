# DO NOT RUN THIS WITH MORE CORES (run only one core because of sudo requests)

user = tomato
home = /home/tomato
programs = $(home)/Programs
configDir = $(home)/.config
dotfilesDir = $(home)/dotfiles
bashDir = $(dotfilesDir)/bash
i3Dir = $(dotfilesDir)/i3
i3varDir = $(i3Dir)/variables
i3blocksDir = $(dotfilesDir)/i3blocks
xkbDir = $(dotfilesDir)/xkb
cme = $(home)/NetBeansProjects/cme
workConf = $(dotfilesDir)/Work/config

.PHONY: all config i3blocks bash bash-tab git nvim ranger redshift pureline xkb opera conky rofi flameshot discord spotify rofimoji grub chrome slack php composer work

all: update config i3blocks bash bash-tab git nvim ranger redshift pureline xkb opera conky rofi flameshot discord spotify rofimoji

update:
	@echo "[INFO] Updating pacman..."
	@sudo pacman -Syu --noconfirm > /dev/null
	@echo "[DONE] Update completed."

config:
	@echo -n "Choose which i3 configuration (variables pack) you want:"
	@for file in ./i3/variables/*; do echo -n " $${file##*/}"; done; echo ""
	@cat $(i3Dir)/header > $(i3Dir)/config
	@var=null; until [ -f "/home/tomato/dotfiles/i3/variables/$${var}" ]; do read -p "Choice: " var; done; \
		cat $(i3varDir)/$${var} >> $(i3Dir)/config
	@cat $(i3Dir)/base >> $(i3Dir)/config
	@echo "[DONE] Created i3 config file."
	@rm -rf $(home)/.i3
	@ln -s $(i3Dir) $(home)/.i3
	@echo "[DONE] Linked i3 conf folder."

time:
	@echo "[INFO] Setting time to use RTC..."
	@sudo timedatectl set-local-rtc 1
	@echo "[DONE] Time set."

i3blocks:
	@echo "[INFO] Installing i3blocks..."
	@sudo pamac install --no-confirm i3blocks > /dev/null
	@echo "[DONE] Installed i3blocks."
	@for file in $(i3blocksDir)/scripts/*; do chmod +x $$file; done
	@rm -rf $(configDir)/i3blocks
	@ln -s $(dotfilesDir)/i3blocks $(configDir)/i3blocks
	@echo "[DONE] Linked i3blocks config folder."

bash:
	@echo "[INFO] Installing gnome terminal..."
	@sudo pacman -S --needed --noconfirm gnome-terminal > /dev/null
	@echo "[DONE] Installed gnome terminal."
	@if [[ $$(cat $(home)/.bashrc | grep "# Include bash configuration from dotfiles") ]]; then echo "[INFO] Bash config already imported in .bashrc..."; else \
	echo -n "Choose which bash configuration you want:"; \
	for file in $(bashDir)/*; do if [ ! -d $${file} ]; then echo -n " $${file##*/}"; fi; done; echo ""; \
	var=null; until [ -f "/home/tomato/dotfiles/bash/$${var}" ]; do read -p "Choice: " var; done; \
		echo -e "\n# Include bash configuration from dotfiles\nsource $(bashDir)/$${var}" >> $(home)/.bashrc; fi

bash-tab:
	@echo "[INFO] Setting up bash autocompletion case-insensitive..."
	@if ! [[ $$(cat /etc/inputrc | egrep "set\s+completion-ignore-case\s+On") ]]; then echo "set completion-ignore-case On" | sudo tee -a /etc/inputrc > /dev/null; fi

git:
	@echo "[INFO] Preparing git configuration..."
	@rm -f $(home)/.gitconfig
	@cp $(dotfilesDir)/.gitconfig $(home)/.gitconfig
	@echo "[DONE] Copied gitconfig file for global git configuration."
	@echo -n "Please write your name for global git configuration: "; read name; git config --global user.name "$${name}"
	@echo -n "Please write your email for global git configuration: "; read email; git config --global user.email "$${email}"

nvim: nvim-plug
	@echo "[INFO] Installing neovim..."
	@sudo pacman -S --needed --noconfirm neovim > /dev/null
	@echo "[DONE] Installed neovim."
	@rm -rf $(configDir)/nvim
	@ln -s $(dotfilesDir)/nvim $(configDir)/nvim
	@echo "[DONE] Linked neovim config folder."

nvim-plug:
	@echo "[INFO] Downloading nvim plug manager..."
	@sh -c 'curl -fLo $(home)/.local/share/nvim/site/autoload/plug.vim --create-dirs \
       https://raw.githubusercontent.com/junegunn/vim-plug/master/plug.vim' > /dev/null
	@echo "[DONE] Downloaded."
	@echo "[INFO] Downloading node.js for coc.nvim..."
	@sudo curl -sL install-node.now.sh/lts | sudo bash
	@echo "[DONE] Installed node.js."
	@echo "[DONE] Installing pynvim and ueberzug for rnvimr..."
	@pip3 install pynvim > /dev/null
	@pip3 install ueberzug > /dev/null
	@echo "[DONE] Installed plug dependencies."

ranger:
	@echo "[INFO] Installing ranger..."
	@sudo pacman -S --needed --noconfirm ranger > /dev/null
	@echo "[DONE] Installed ranger."
	@rm -rf $(configDir)/ranger
	@ln -s $(dotfilesDir)/ranger $(configDir)/ranger
	@echo "[DONE] Linked ranger config folder."

redshift:
	@echo "[INFO] Installing redshift..."
	@sudo pacman -S --needed --noconfirm redshift > /dev/null
	@echo "[DONE] Installed redshift."
	@rm -rf $(configDir)/redshift
	@ln -s $(dotfilesDir)/redshift $(configDir)/redshift
	@echo "[DONE] Linked redshift config folder."

pureline:
	@echo "[INFO] Installing pureline..."
	@mkdir -p $(programs)
	@if [ ! -d "$(programs)/pureline" ]; then git clone -q https://github.com/chris-marsh/pureline.git $(programs)/pureline > /dev/null; fi
	@chmod +x $(programs)/pureline/pureline
	@echo "[DONE] Installed pureline."
	@echo "[WARN] Rollbacking pureline to commit a410b02 (last update of config)."
	@git --git-dir $(programs)/pureline/.git reset --hard a410b02
	@rm -rf $(configDir)/pureline
	@ln -s $(dotfilesDir)/pureline $(configDir)/pureline
	@echo "[DONE] Linked pureline config folder."

xkb:
	@echo "[INFO] Applying my keyboard settings..."
	@sudo rm -f /usr/share/X11/xkb/symbols/cz
	@sudo ln -s $(xkbDir)/my_cz /usr/share/X11/xkb/symbols/cz
	@setxkbmap cz -model pc105
	@echo "[DONE] Linked my keyboard settings."

opera:
	@echo "[INFO] Installing opera..."
	@sudo snap install opera > /dev/null
	@echo "[DONE] Opera installed."

conky:
	@echo "[INFO] Linking conky config..."
	@sudo rm -f /usr/share/conky/conky_green
	@sudo ln -s $(dotfilesDir)/conky/conky_green /usr/share/conky/conky_green
	@echo "[DONE] Linked config file."

rofi:
	@echo "[INFO] Installing rofi menu..."
	@sudo pacman -S --needed --noconfirm rofi > /dev/null
	@echo "[DONE] Installed rofi menu..."

flameshot:
	@echo "[INFO] Installing flameshot..."
	@sudo pacman -S --needed --noconfirm flameshot > /dev/null
	@echo "[DONE] Installed flameshot..."

grub:
	@echo "[INFO] Installing grub customizer..."
	@sudo pamac install --no-confirm grub-customizer > /dev/null
	@echo "[DONE] Installed grub customizer."

discord:
	@echo "[INFO] Installing discord..."
	@sudo snap install discord > /dev/null
	@echo "[DONE] Installed discord"

chrome:
	@echo "[INFO] Installing chrome..."
	@sudo pamac install --no-confirm google-chrome > /dev/null
	@echo "[DONE] Installed chrome..."

slack:
	@echo "[INFO] Downloading slack..."
	@sudo snap install --classic slack > /dev/null
	@echo "[DONW] Installed slack."

spotify:
	@echo "[INFO] Installing spotify..."
	@sudo snap install spotify > /dev/null
	@echo "[DONE] Installed spotify."

rofimoji:
	@echo "[INFO] Installing rofimoji..."
	@sudo pacman -S --needed --noconfirm emoji-font python rofi xdotool xsel
	@echo "[DONE] Installed rofimoji."

php:
	@echo "[INFO] Installing php and apache..."
	@echo "[WARN] There could be problem with key signatures. If so, install via pamac gui php56 and other php56 dep. This should add these keys."
	@sudo pamac install --no-confirm apache php php-apache php-cgi php-fpm php-gd php-intl php-pgsql php56 php56-apache php56-cgi php56-fpm php56-gd php56-intl php56-sqlite > /dev/null
	@echo "[DONE] Installed apache and php56/72."

composer:
	@echo "[INFO] Installing composer..."
	@curl -sS https://getcomposer.org/installer | php
	@sudo mv composer.phar /usr/local/bin/composer
	@sudo systemctl restart httpd
	@sudo composer self-update
	@echo "[DONE] Installed composer."

work: update chrome slack php composer
	@echo "[INFO] Starting setup for work enviroment..."
	@mkdir -p $(home)/NetBeansProjects
	@read -p "Add ssh key of this pc to bitbucket and press enter..."
	@if [ ! -d $(cme) ]; then git clone -q git@bitbucket.org:internethandel/cme.git $(cme) > /dev/null; fi
	@if ! [[ $$(sudo cat /etc/hosts | egrep "127.0.0.1\s+cme") ]]; then echo "127.0.0.1	cme" | sudo tee -a /etc/hosts; fi
	@sudo mkdir -p /var/log/apache/cme
	@sudo mkdir -p /etc/httpd/conf/sites-enabled
	@sudo rm -f /etc/httpd/conf/sites-enabled/001-cme.conf
	@sudo ln -s $(workConf)/001-cme.conf /etc/httpd/conf/sites-enabled/001-cme.conf
	@sudo rm /etc/httpd/conf/extra/httpd-default.conf
	@sudo ln -s $(workConf)/httpd-default.conf /etc/httpd/conf/extra/httpd-default.conf
	@sudo rm /etc/php/php.ini
	@sudo rm /etc/php56/php.ini
	@sudo ln -s $(workConf)/php.ini /etc/php/php.ini
	@sudo ln -s $(workConf)/php56.ini /etc/php56/php.ini
	@sudo rm /etc/httpd/conf/httpd.conf
	@sudo ln -s $(workConf)/httpd.conf /etc/httpd/conf/httpd.conf
	@sudo rm -f /etc/httpd/conf/extra/php-fpm.conf
	@sudo ln -s $(workConf)/php-fpm.conf /etc/httpd/conf/extra/php-fpm.conf
	@sudo rm -f /etc/httpd/conf/extra/httpd-vhosts.conf
	@sudo ln -s $(workConf)/httpd-vhosts.conf /etc/httpd/conf/extra/httpd-vhosts.conf
	@cp $(cme)/inc-local.php.example $(cme)/inc-local.php
	@echo "[WARN] Don't forget to setup inc-local file."
	#@cd $(cme)/skripty/composer-php56/; composer install; cd ../composer-php72/; composer install
	@sudo systemctl restart php56-fpm
	@sudo systemctl restart php-fpm
	@sudo systemctl restart httpd
	@echo "[DONE] Work env setup done."
