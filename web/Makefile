
HTDOCS = shell.sourceforge.net:/home/groups/m/me/meanwhile/htdocs

all:
	make -C faq

upload:	all
	rsync -zur -e ssh --delete * $(HTDOCS)


