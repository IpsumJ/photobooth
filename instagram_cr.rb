#!/usr/bin/env ruby
require 'selenium-webdriver'

img = ARGV[0]
caption = ARGV[1]

args = [
'--window-size=240,580',
'--user-data-dir=./chromium',
'--user-agent=Mozilla/5.0 (Linux; Android 6.0; Nexus 5 Build/MRA58N) AppleWebKit/537.36 (KHTML, like Gecko) Chrome/63.0.3239.84 Mobile Safari/537.36']

options = Selenium::WebDriver::Chrome::Options.new(args: args)

driver = Selenium::WebDriver.for(:chrome, options: options)

driver.get('https://instagram.com')

sleep 3
if ARGV[2] == '-d'
  $stdin.gets
  driver.quit
  exit
end

img_btn = driver.find_element(:xpath, '//*[@id="react-root"]/section/nav[2]/div/div/div[2]/div/div/div[3]')
form = driver.find_element(:xpath, '//*[@id="react-root"]/section/nav[2]/div/div/form/input')

img_btn.click
form.send_keys(File.absolute_path img)

sleep 0.3

scale_btn = driver.find_element(:xpath, '//*[@id="react-root"]/div/div[2]/div[2]/div/div/div/button[1]')
scale_btn.click

sleep 0.1

next_btn = driver.find_element(:xpath, '//*[@id="react-root"]/div/div[1]/header/div[2]/button')
next_btn.click

sleep 3

tχt_area = driver.find_element(:xpath, '//*[@id="react-root"]/div/div[2]/section[1]/div/textarea')
tχt_area.click
tχt_area.send_keys(caption)

sleep 0.5

share_btn = driver.find_element(:xpath, '//*[@id="react-root"]/div/div[1]/header/div[2]/button')
share_btn.click

sleep 2

driver.quit
