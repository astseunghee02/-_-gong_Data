from selenium import webdriver
from selenium.webdriver.chrome.service import Service
from selenium.webdriver.common.by import By
from selenium.webdriver.support.ui import WebDriverWait
from selenium.webdriver.support import expected_conditions as EC
from selenium.webdriver.support.ui import Select
import time


# 로그인 과정
def login(phone_front, phone_back, password):
    button = wait.until(EC.element_to_be_clickable((By.ID, "radInputFlg2")))
    button.click()

    driver.find_element(By.ID, "txtCpNo2").send_keys(phone_front)  # 전화번호 앞자리
    driver.find_element(By.ID, "txtCpNo3").send_keys(phone_back)  # 전화번호 뒷자리
    driver.find_element(By.ID, "txtPwd1").send_keys(password)  # 비번

    login_button = wait.until(EC.element_to_be_clickable((By.XPATH, "//*[@id='loginDisplay2']/ul/li[3]/a/img")))
    login_button.click()


# 예약 시작 버튼 클릭
def click_reservation_tab(tab_xpath):
    tab_button = wait.until(EC.element_to_be_clickable((By.XPATH, tab_xpath)))
    tab_button.click()


# 창 전환 함수
def switch_window(handle_index):
    handles = driver.window_handles
    # 인덱스가 유효한지 확인하고 전환
    if handle_index < len(handles):
        driver.switch_to.window(handles[handle_index])
    else:
        print(f"Error: Handle index {handle_index} out of range.")


# 예약 버튼 클릭 후 이동
def select_station(xpath, switch_to_new_tab=True):
    station_button = wait.until(EC.element_to_be_clickable((By.XPATH, xpath)))
    station_button.click()

    if switch_to_new_tab:
        switch_window(1)
        time.sleep(2)


# 날짜 및 시간 선택
def select_date_and_time(month_value, day_value, hour_value):
    month_element = wait.until(EC.presence_of_element_located((By.ID, "s_month")))
    month_select = Select(month_element)
    month_select.select_by_value(month_value)

    day_element = wait.until(EC.presence_of_element_located((By.ID, "s_day")))
    day_select = Select(day_element)
    day_select.select_by_value(day_value)

    hour_element = wait.until(EC.presence_of_element_located((By.ID, "s_hour")))
    hour_select = Select(hour_element)
    hour_select.select_by_value(hour_value)


# 메인 프로세스
def main(phone_front, phone_back, password, selected_month, selected_day, selected_hour):
    # ChromeDriver 경로 설정
    service = Service("/opt/homebrew/bin/chromedriver")
    driver = webdriver.Chrome(service=service)

    # URL 접속
    driver.get("https://www.letskorail.com/korail/com/login.do")
    wait = WebDriverWait(driver, 10)  # 명시적 대기 객체 생성

    login(phone_front, phone_back, password)  # 로그인 정보
    time.sleep(2)

    click_reservation_tab("//*[@id='res_cont_tab01']/form/div/fieldset/ul[1]/li[1]/a/img")
    switch_window(1)

    # 순천 예약 버튼 클릭
    select_station("/html/body/div/div[2]/table/tbody/tr[7]/td[4]/a")
    switch_window(0)

    # 종료역 버튼 클릭
    click_reservation_tab("//*[@id='res_cont_tab01']/form/div/fieldset/ul[1]/li[2]/a/img")
    time.sleep(2)
    switch_window(1)

    # 천안 예약 버튼 클릭
    select_station("/html/body/div/div[2]/table/tbody/tr[2]/td[2]/a")
    switch_window(0)

    # 예약 버튼 클릭
    res_button = wait.until(
        EC.element_to_be_clickable((By.XPATH, "//*[@id='res_cont_tab01']/form/div/fieldset/p/a/img")))
    res_button.click()

    time.sleep(2)

    # 날짜와 시간 선택
    select_date_and_time(selected_month, selected_day, selected_hour)

    # 검색 버튼 클릭
    search_button = wait.until(EC.element_to_be_clickable((By.XPATH, "//*[@id='center']/div[3]/p/a/img")))
    search_button.click()

    try:
        # XPath에서 예약 가능 상태 버튼 찾기
        available_button = WebDriverWait(driver, 10).until(
            EC.presence_of_element_located((By.XPATH, '//*[@id="tableResult"]/tbody/tr[1]/td[6]/a[1]/img'))
        )
        available_button.click()

        print("예약 가능 버튼을 클릭했습니다.")
    except:
        print("예약 가능 버튼을 찾지 못했거나 클릭할 수 없습니다.")

    # 대기 시간
    time.sleep(1000)


# //*[@id="tableResult"]/tbody/tr[1]/td[6]/img
# //*[@id="tableResult"]/tbody/tr[1]/td[6]/a[1]/img
# //*[@id="tableResult"]/tbody/tr[2]/td[6]/a[1]/img
# 프로그램 실행

