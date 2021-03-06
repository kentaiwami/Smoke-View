import RPi.GPIO as GPIO
import time
import urllib.request
import json
from queue import Queue
import os
import sqlite3
import setting
import csv
from datetime import datetime
from setting import base_url


# change these as desired - they're the pins connected from the
# SPI port on the ADC to the Cobbler
SPICLK = 11
SPIMISO = 9
SPIMOSI = 10
SPICS = 8
mq7_dpin = 26
mq7_apin = 0

SMOKE_ID = '0'
UUID = ''


# port init
def init():
    GPIO.setwarnings(False)
    GPIO.cleanup()  # clean up at the end of your script
    GPIO.setmode(GPIO.BCM)  # to specify whilch pin numbering system
    # set up the SPI interface pins
    GPIO.setup(SPIMOSI, GPIO.OUT)
    GPIO.setup(SPIMISO, GPIO.IN)
    GPIO.setup(SPICLK, GPIO.OUT)
    GPIO.setup(SPICS, GPIO.OUT)
    GPIO.setup(mq7_dpin, GPIO.IN, pull_up_down=GPIO.PUD_DOWN)


# read SPI data from MCP3008(or MCP3204) chip,8 possible adc's (0 thru 7)
def readadc(adcnum, clockpin, mosipin, misopin, cspin):
    if adcnum > 7 or adcnum < 0:
        return -1
    GPIO.output(cspin, True)

    GPIO.output(clockpin, False)  # start clock low
    GPIO.output(cspin, False)  # bring CS low

    commandout = adcnum
    commandout |= 0x18  # start bit + single-ended bit
    commandout <<= 3  # we only need to send 5 bits here
    for i in range(5):
        if commandout & 0x80:
            GPIO.output(mosipin, True)
        else:
            GPIO.output(mosipin, False)
        commandout <<= 1
        GPIO.output(clockpin, True)
        GPIO.output(clockpin, False)

    adcout = 0
    # read in one empty bit, one null bit and 10 ADC bits
    for i in range(12):
        GPIO.output(clockpin, True)
        GPIO.output(clockpin, False)
        adcout <<= 1
        if GPIO.input(misopin):
            adcout |= 0x1

    GPIO.output(cspin, True)

    adcout >>= 1  # first bit is 'null' so drop it
    return adcout


def main():
    global UUID, SMOKE_ID

    # DBが作成されるまで何もしない
    db_filename = setting.DB_PATH

    while True:
        if os.path.exists(db_filename):
            break

    # DBとのコネクション生成
    conn = sqlite3.connect(db_filename)
    c = conn.cursor()

    co_queue = Queue()
    co_queue.maxsize = 30

    is_started = False
    co_difference_threshold = 0.5

    min_difference_count = -1
    prev_co = 0.0

    init()
    print("please wait...")
    time.sleep(20)

    select_sql = 'select count(*), uuid from user'

    while True:
        user = c.execute(select_sql)
        results = user.fetchone()

        # print(co_queue.empty(), UUID, SMOKE_ID, is_started)

        # UUIDの保存件数が0件の場合は何もしないでひたすらスキップ
        if results[0] == 0:
            print('no user data')

            # 初期化
            co_queue.queue.clear()
            UUID = ''
            SMOKE_ID = '0'
            is_started = False
            min_difference_count = -1
            prev_co = 0.0

            time.sleep(1.5)
            continue
        else:
            UUID = results[1]

        COlevel = readadc(mq7_apin, SPICLK, SPIMOSI, SPIMISO, SPICS)
        COpercent = (COlevel / 1024.) * 100

        write_file(COpercent=COpercent)

        # 値がおかしい時は処理をスキップ
        if COpercent > 30.0:
            time.sleep(1.5)
            continue

        # キューのサイズを超えないようにCO値を格納
        if co_queue.full():
            co_queue.get()
            co_queue.put(COpercent)
        else:
            co_queue.put(COpercent)

        ave = sum(list(co_queue.queue)) / co_queue.qsize()

        co_difference = COpercent - ave

        # CO値の差分が閾値を超えたらsmoke作成APIを叩く
        if co_difference > co_difference_threshold and not is_started:
            run_api(is_create=True)
            is_started = True

            prev_co = COpercent
            co_queue.queue.clear()

            print('start', ave, COpercent)

        # 喫煙終了判定開始
        if is_started:
            if COpercent - prev_co > 0.1:
                min_difference_count = 0
            else:
                min_difference_count += 1

            print(min_difference_count, COpercent - prev_co)

            if min_difference_count == 30:
                run_api(is_create=False)
                is_started = False
                min_difference_count = -1

                print('end', ave, COpercent)

        prev_co = COpercent

        print("Current CO density is:" + str("%f" % ((COlevel / 1024.) * 100)) + " %")

        time.sleep(1.5)


def run_api(is_create):
    global SMOKE_ID

    obj = {
        'uuid': UUID,
        'minus_sec': 30,
        'is_sensor': True
    }

    if is_create:
        api_url = base_url + ''
        method = 'POST'

    else:
        api_url = base_url + str(SMOKE_ID)
        method = 'PUT'

    json_data = json.dumps(obj).encode("utf-8")
    headers = {"Content-Type": "application/json"}

    request = urllib.request.Request(api_url, data=json_data, headers=headers, method=method)
    response = urllib.request.urlopen(request)
    response_body = response.read().decode("utf-8")
    result_objs = json.loads(response_body.split('\n')[0])

    SMOKE_ID = result_objs['smoke_id']


def write_file(COpercent):
    folder = '/home/pi/Documents/sumolog/log'

    if not os.path.isdir(folder):
        os.mkdir(folder)

    try:
        now = datetime.now()
        file_name = '{0:%Y-%m-%d}.csv'.format(now)
        with open(folder + '/' + file_name, 'a') as csvfile:
            writer = csv.writer(csvfile, lineterminator='\n')
            writer.writerow([datetime.now().strftime('%Y/%m/%d %H:%M:%S'), COpercent])

    except:
        pass


if __name__ == '__main__':
    try:
        main()
        pass
    except KeyboardInterrupt:
        pass

GPIO.cleanup()
