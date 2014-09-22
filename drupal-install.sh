#!/bin/bash

# Text color variables
txtund=$(tput sgr 0 1)          # Underline
txtbld=$(tput bold)             # Bold
txtred=$(tput setaf 1)          #  red
txtgre=$(tput setaf 2)          #  green
txtyel=$(tput setaf 3)          #  yellow
txtblu=$(tput setaf 4)          #  blue
bldred=${txtbld}$(tput setaf 1) #  red
bldblu=${txtbld}$(tput setaf 4) #  blue
bldwht=${txtbld}$(tput setaf 7) #  white
txtrst=$(tput sgr0)             # Reset
info=${bldwht}*${txtrst}        # Feedback
pass=${bldblu}*${txtrst}
warn=${bldred}*${txtrst}
ques=${bldblu}?${txtrst}

# Functions
#
check_connection() {
  # checks MySQL Connection
  result=0
  DB_Host=localhost

  until [[ $result = "1" ]]; do

    while [[ $DB_User = "" ]]; do
      read -p "Please enter DB User: " DB_User
    done

    while [[ $DB_User_Pass = "" ]]; do
      echo -n 'Please enter DB User Password for $DB_User (input hidden): '
      stty -echo
      read DB_User_Pass
      stty echo
    done
    read -p "Plaese enter DB Host [$DB_Host]: " DB_Host

    MySQL_Con=$(mysql -u $DB_User --password=$DB_User_Pass --host=$DB_Host -e "show databases;"|grep "mysql")
    if ! [[ $MySQL_Con = "mysql" ]]; then
      DB_User=""
      DB_User_Pass=""
      DB_Host=localhost
    else
      result=1
      echo "Connection works great!"
    fi
  done
}

check_DB(){
  result=0
  until [[ $result = "1" ]]; do
    while [[ $DB_Name = "" ]]; do
      read -p "Please enter DB Name: " DB_Name
    done
    DB_Con=$(mysql -u $DB_User --password=$DB_User_Pass --host=$DB_Host -e "show databases;"|grep "$DB_Name")
    if [[ $DB_Name = $DB_Con ]]; then
      result=1
      echo "DB exists!"
    else
      #TODO: Add DB and grand permission
      DB_Name=""
    fi
  done

}

set_Drupal_Install(){
  while [[ $Drupal_Admin = "" ]]; do
    read -p "Please enter Drupal Admin: " Drupal_Admin
  done

  while [[ $Drupal_Admin_Pass = "" ]]; do
    echo -n 'Please enter Password for $Drupal_Admin (input hidden): '
    stty -echo
    read Drupal_Admin_Pass
    stty echo
  done

  while [[ $Drupal_Admin_Mail = "" ]]; do
    read -p "Please enter Drupal Admin Mail: " Drupal_Admin_Mail
  done

  while [[ $Drupal_Site_Name = "" ]]; do
    read -p "Please enter Drupal Site Name: " Drupal_Site_Name
  done

}

echo $bldblu
echo "*******************************************************************"
echo "*                                                                 *"
echo "*                     Drupal installation script                  *"
echo "*                                                                 *"
echo "*******************************************************************"
echo $txtrst
echo -e $txtred"DISCLAIMER OF WARRANTY\n
The Software is provided \"AS IS\" and \"WITH ALL FAULTS,\"
without warranty of any kind, including without limitation
the warranties of merchantability, fitness for a particular
purpose and non-infringement. The Licensor makes no warranty
that the Software is free of defects or is suitable for any
particular purpose. In no event shall the Licensor be responsible
for loss or damages arising from the installation or use of the
Software, including but not limited to any indirect, punitive,
special, incidental or consequential damages of any character
including, without limitation, damages for loss of goodwill, work
stoppage, computer failure or malfunction, or any and all other
commercial damages or losses. The entire risk as to the quality
and performance of the Software is borne by you. Should the Software
prove defective, you and not the Licensor assume the entire cost of
any service and repair.\n"


# checks if drush and wget is installed
command -v drush >/dev/null 2>&1 || { echo >&2 "Drush is required, but it's not installed. Aborting."; exit 1; }
command -v wget >/dev/null 2>&1 || { echo >&2 "wget is required, but it's not installed. Aborting."; exit 1; }

echo $txtgre"Start installing the latest version of Drupal\n"$txtrst

check_connection
check_DB
set_Drupal_Install


echo -e $txtgre"\nBuild Drupal Filestructure\n"$txtrst
drush make makefiles/drupal.make --y
echo -e $txtgre"\nStating the installation of core\n"$txtrst
drush si -y --db-url=mysql://$DB_User:$DB_User_Pass@$DB_Host/$DB_Name --account-name=$Drupal_Admin --account-pass=$Drupal_Admin_Pass --account-mail=$Drupal_Admin_Mail --site-name=$Drupal_Site_Name

read -p "Download Features? " -n 1 -r
echo    # (optional) move to a new line
if [[ $REPLY =~ ^[Yy]$ ]]
then
    drush make makefiles/features.make --y
fi


#drush make makefiles/views.make --y

#drush make makefiles/theme.make --y



#echo "Select Drupal theme to install"
#PS3='Please enter your choice: '
#options=("Bootstrap $txtyel(https://drupal.org/project/bootstrap)$txtrst" "Zurb Foundation $txtyel(https://drupal.org/project/zurb-foundation)$txtrst" "Omega $txtyel(https://drupal.org/project/omega)$txtrst")
#select opt in "${options[@]}"
#do
#    case "$REPLY" in
#        1 )
#            drupaltheme=bootstrap
#            drupalthemedefault=bootstrap
#            break
#            ;;
#        2 )
#            drupaltheme=zurb-foundation
#            drupalthemedefault=zurb_foundation
#            break
#            ;;
#        3 )
#            drupaltheme=omega
#            drupalthemedefault=omega
#            break
#            ;;
#        *) echo invalid option;;
#    esac
#done
#
#read -p "Start installation? [Y/N] " -n 1 -r
#echo    # (optional) move to a new line
#if [[ $REPLY =~ ^[Yy]$ ]]
#then
#  echo -e $txtgre"\nDownloading the latest version of drupal\n"$txtrst
#  drush dl drupal --drupal-project-rename drupal
#  cd drupal
#
#  echo -e $txtgre"\nStating the installation of core\n"$txtrst
#  drush si -y --db-url=mysql://$DB_User:$DB_User_Pass@$DB_Host/$mysqldatabase --account-name=$drupaladminusernmae --account-pass=$drupaladminpassword --account-mail=$drupaladminmail
#
#  echo -e $txtgre"\nDownload and set admin theme to Adminimal\n"$txtrst
#  drush dl adminimal_theme
#  drush variable-set admin_theme adminimal
#
#  echo -e $txtgre"\nDisable unusable core modules"$txtrst
#  drush dis toolbar overlay contextual -y
#
#  echo -e $txtgre"\nDownload modules and enable them\n"$txtrst
#  drush dl ctools devel features entity panels views admin_menu adminimal_admin_menu pathauto strongarm token module_filter link field_group advanced_help libraries
#  drush en ctools ctools_custom_content page_manager devel features entity entity_token panels panels_mini views views_ui views_content admin_menu adminimal_admin_menu pathauto strongarm token module_filter link field_group advanced_help libraries -y
#
#  echo -e $txtgre"\nDownload and install Backup and Migrate module\n"$txtrst
#  cd sites/all/
#  mkdir -p "libraries"
#  cd libraries
#  mkdir -p "dropbox"
#  cd ../../../
#  wget https://github.com/BenTheDesigner/Dropbox/archive/master.zip
#  tar -xf master.zip
#  mv "Dropbox-master/Dropbox/" "sites/all/libraries/dropbox"
#  rm -rf Dropbox-master
#  rm master.zip
#  drush dl backup_migrate backup_migrate_files backup_migrate_dropbox
#  drush en backup_migrate backup_migrate_files backup_migrate_dropbox -y
#
#  echo -e $txtgre"\nFix for Admin menu and Adminimal menu\n"$txtrst
#  drush variable-set admin_menu_margin_top 0
#  drush variable-set adminimal_admin_menu_render "hidden"
#
#  echo -e $txtgre"\nInstall jQuery Update\n"$txtrst
#  drush dl jquery_update-7.x-2.x-dev
#  drush en jquery_update -y
#  drush variable-set --format="string" jquery_update_jquery_version "1.10"
#  drush variable-set --format="string" jquery_update_jquery_admin_version "1.7"
#  drush variable-set --format="string" jquery_update_jquery_cdn "google"
#  drush variable-set --format="string" jquery_update_compression_type "min"
#  drush cc all
#
#  echo -e $txtgre"\nInstall $drupaltheme theme\n"$txtrst
#  drush dl $drupaltheme
#  drush pm-enable $drupaltheme -y
#  drush variable-set theme_default "$drupalthemedefault"
#
#  echo -e $txtgre"\nDisable unused themes\n"$txtrst
#  drush pm-disable bartik -y
#  drush pm-disable seven -y
#
#  echo -e $txtgre"\nInstallation is finished\n"$txtrst
#  echo -e $txtblu"Login information:"
#  echo -e $txtgre"Username:$txtred $drupaladminusernmae"
#  echo -e $txtgre"Password:$txtred $drupaladminpassword"
#  echo $txtrst
#fi
#

