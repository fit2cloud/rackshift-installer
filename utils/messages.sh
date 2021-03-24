#!/bin/bash
#

function init_message() {
    find . -iname "*.sh" | xargs  xgettext --output=/tmp/rackshift-installer.pot --from-code=UTF-8

    msginit --input=/tmp/rackshift-installer.pot --locale=locale/zh_CN/LC_MESSAGES/rackshift-installer.po

    msginit --input=/tmp/rackshift-installer.pot --locale=locale/en/LC_MESSAGES/rackshift-installer.po
}

function make_message() {

    find . -iname "*.sh" | xargs  xgettext --output=/tmp/rackshift-installer.pot --from-code=UTF-8

    msginit --input=/tmp/rackshift-installer.pot --locale=locale/zh_CN/LC_MESSAGES/rackshift-installer-tmp.po
    msgmerge -U locale/zh_CN/LC_MESSAGES/rackshift-installer.po locale/zh_CN/LC_MESSAGES/rackshift-installer-tmp.po

    msginit --input=/tmp/rackshift-installer.pot --locale=locale/en/LC_MESSAGES/rackshift-installer-tmp.po
    msgmerge -U locale/en/LC_MESSAGES/rackshift-installer.po locale/en/LC_MESSAGES/rackshift-installer-tmp.po

    rm ./locale/zh_CN/LC_MESSAGES/rackshift-installer-tmp.po
    rm ./locale/en/LC_MESSAGES/rackshift-installer-tmp.po
}

function compile_message() {
   msgfmt --output-file=locale/zh_CN/LC_MESSAGES/rackshift-installer.mo locale/zh_CN/LC_MESSAGES/rackshift-installer.po

   msgfmt --output-file=locale/en/LC_MESSAGES/rackshift-installer.mo locale/en/LC_MESSAGES/rackshift-installer.po
}

action=$1
if [ -z "$action" ]; then
    action="make"
fi

case $action in
    m|make)
        make_message;;
    i|init)
        init_message;;
    c|compile)
        compile_message;;
    *)
        echo "Usage: $0 [m|make i|init | c|compile]"
        exit 1
        ;;
esac
