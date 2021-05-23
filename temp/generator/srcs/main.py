#
# Copyright (c) 2021 Maxim Gazizov All rights reserved.
# Use of this source code is governed by a BSD-style
# license that can be found in the LICENSE file.

import os
import random
import string
import numpy
import pandas as pd
import time
import locale

locale.setlocale(locale.LC_TIME, 'ru_RU.UTF-8')
overall_hours_in_year = 1122
year = 2020
csv_dir = os.getenv("CSV_DIR")

marks = [2, 3, 4, 5]
subjects = [
	"Русский язык",
	"Литература",
	"Родной(русский) язык",
	"Иностранный язык",
	"История",
	"Обществознание",
	"Математика",
	"Информатика",
	"Астрономия",
	"Физика",
	"Физкультура",
	"ОБЖ",
	"География",
	"Биология",
	"Химия",
	"Финансовая грамотность"
]

distributions = [34, 102, 34, 102, 68, 68, 204, 136, 34, 68, 102, 34, 34, 34, 34, 34]
percentile = []
total_percentile = 0
for _ in distributions:
	percentile.append(_ / overall_hours_in_year)
	total_percentile += _ / overall_hours_in_year
print(percentile)
print(total_percentile)

holidays_list = [
	f"{year}-01-01", f"{year}-01-02", f"{year}-01-03", f"{year}-01-04",
	f"{year}-01-05", f"{year}-01-06", f"{year}-01-07", f"{year}-01-08", f"{year}-01-09",
	f"{year}-01-10", f"{year}-01-11", f"{year}-01-12", f"{year}-01-13", f"{year}-02-23",
	f"{year}-05-01", f"{year}-05-02", f"{year}-05-09", f"{year}-11-05", f"{year}-12-31",
	f"{year}-01-01"]

days_range = pd.bdate_range(f"{year}-09-01", f"{year + 1}-05-31", weekmask="1111110", holidays=holidays_list,
							freq="C").strftime("%x")


def get_random_string():
	return ''.join(random.sample(string.ascii_letters, k=random.randrange(2, 18)))


def get_random_name():
	return f"{get_random_string()} {get_random_string()} {get_random_string()}"


scholar_count = 300
scholar_names = [get_random_name() for _ in range(scholar_count)]


def get_random_scholar_name():
	numpy.random.choice(scholar_names)


def get_random_mark():
	return numpy.random.choice(marks, p=[0.1, 0.25, 0.4, 0.25])


def get_random_subject():
	return numpy.random.choice(subjects, p=percentile)


def get_random_date():
	return numpy.random.choice(days_range)


def get_random_data_string():
	return f"{numpy.random.choice(scholar_names)},{get_random_subject()},{get_random_mark()},{get_random_date()}{os.linesep}"


def get_file_size_GB(path="marks.csv"):
	try:
		return os.path.getsize(path) / 2 ** 30
	except OSError:
		return 0


print(len(subjects))
print(len(percentile))

fieldnames = ["Name", "Subject", "Mark", "Date"]

rows = random.randint(10 ** 10, 10 ** 15)

dif_size = 10 ** 6  # is about 0.0625GB
wanted_size = random.randint(1, 10)
iterations = 1 / 0.0625

# path = filename
# iterations = 2
# dif_size = 5

while True:
	path = f"{csv_dir}/{get_random_string()}.csv"
	try:
		start_time = time.monotonic()
		for _ in range(round(iterations * wanted_size)):
			pd.DataFrame({
				"Name": numpy.random.choice(scholar_names, size=dif_size),
				"Subject": numpy.random.choice(subjects, p=percentile, size=dif_size),
				"Mark": numpy.random.choice(marks, p=[0.1, 0.25, 0.4, 0.25], size=dif_size),
				"Date": numpy.random.choice(days_range, size=dif_size)}
			).to_csv(path, mode='a', index=False, header=(True if _ == 0 else False))
			print(f"Iterations #{_}. Around extra ~ 0.0625GB of csv generated. File size now ~ {(_ + 1) * 0.0625}")
		print(f"{get_file_size_GB(path)}GB {path} generated in {time.monotonic() - start_time} seconds")
	except:
		os.remove(path)
		exit(1)
	time.sleep(600)

