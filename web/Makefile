
HTDOCS = shell.sourceforge.net:/home/groups/m/me/meanwhile/htdocs

all:
	make -C faq

upload:	all
	rsync -v -zur -l -e ssh --delete .htaccess * $(HTDOCS)


