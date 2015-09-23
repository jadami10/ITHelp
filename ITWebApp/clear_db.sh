rm -f tmp.db db.sqlite3
rm -r main/migrations
python manage.py makemigrations main
python manage.py migrate
