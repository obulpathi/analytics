from flask import Flask, render_template
from flaskext.mysql import MySQL

app = Flask(__name__)

app.config["MYSQL_DATABASE_HOST"] = "localhost"
app.config["MYSQL_DATABASE_PORT"] = 3306
app.config["MYSQL_DATABASE_USER"] = "root"
app.config["MYSQL_DATABASE_PASSWORD"] = "84e5beee-aaf7-11e4-b696-180373e4501b"
app.config["MYSQL_DATABASE_DB"] = 'poppy'
# MYSQL_DATABASE_CHARSET	default is 'utf-8'

mysql = MySQL()
mysql.init_app(app)

@app.route('/')
def home():
    return render_template('home.html')

@app.route('/countries')
def countries():
    cursor = mysql.get_db().cursor()
    cursor.execute("SELECT * FROM countries WHERE userid='1'")
    values = {}
    for userid, USA, India, China, Russia, Germany in cursor:
        return render_template('countries.html', USA=USA, India=India, China=China, Russia=Russia, Germany=Germany)

@app.route('/browsers')
def browsers():
    cursor = mysql.get_db().cursor()
    cursor.execute("SELECT * FROM browsers WHERE userid='1'")
    values = {}
    for userid, Chrome, Firefox, IE, Opera in cursor:
        return render_template('browsers.html', Chrome=Chrome, Firefox=Firefox, IE=IE, Opera=Opera)

@app.route('/days')
def days():
    cursor = mysql.get_db().cursor()
    cursor.execute("SELECT * FROM days WHERE userid='1'")
    values = {}
    for userid, day1, day2, day3, day4 in cursor:
        print day1, day2, day3, day4
        return render_template('days.html', day1=day1, day2=day2, day3=day3, day4=day4)

@app.route('/urls')
def urls():
    return render_template('urls.html')

@app.route('/about')
def about():
    return render_template('about.html')

if __name__ == '__main__':
    app.run(debug=True)
