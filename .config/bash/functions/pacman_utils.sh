pacman_executables_of() {
	pacman -Qlq "$*" | perl -nle 'use Term::ANSIColor; print colored($&, 'bright_red') if m{(?<=bin/).+}'
}

pac_cheat() {
	cat <<EOF
Common commands:

pacman -Syzu <pkg>   Install (and update package list)
pacman -S <pkg>      Install only
pacman -Rns <pkg>    Uninstall including deps
pacman -Ss <terms>   Search
pacman -Syu          Upgrade everything

-----------
Query:

pacman -Qe           List explictly-installed packages
pacman -Ql <pkg>     What files does this package have?
pacman -Qii <pkg>    List information on package
pacman -Qo <file>    Who owns this file?
pacman -Qs <query>   Search installed packages for keywords

-----------
Orphans:

pacman -Qdt          List unneeded packages
pacman -Rns \$(pacman -Qdtq)  Uninstall unneeded packages
pacman -Sc           Empty cache

-----------
Dependencies:

pactree <pkg>        What does pkg depend on?
pactree -r <pkg>     What depends on pkg?

-----------
Executables:

pkgfile -s           Find package with executable
EOF
}
