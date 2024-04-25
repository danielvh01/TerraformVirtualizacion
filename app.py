from flask import Flask, jsonify
import datetime
import pytz

app = Flask(__name__)

@app.route('/datetime', methods=['GET'])
def get_datetime():
    now = datetime.datetime.now()
    timezone = pytz.timezone('America/New_York')  # Cambia 'America/New_York' a la zona horaria deseada
    localized_time = timezone.localize(now)
    response = {
        'date': localized_time.strftime("%Y-%m-%d"),
        'time': localized_time.strftime("%H:%M:%S"),
        'timezone': str(localized_time.tzinfo)
    }
    return jsonify(response)

if __name__ == '__main__':
    app.run(host='0.0.0.0', port=3030)
