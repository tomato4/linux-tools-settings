message_info "Linking font folder."
if confirm "This will erase ~/.font folder. Do you want to continue?"
then
    rm -rf $SETUP_HOME/.fonts
    ln -s $DOTFILES/fonts $SETUP_HOME/.fonts
else
    message_error "Operation canceled."
fi
message_done "Operation done."
