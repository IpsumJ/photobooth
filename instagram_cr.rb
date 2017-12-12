#!/usr/bin/env ruby
require 'selenium-webdriver'
require 'selenium/webdriver/common/error'

img = ARGV[0]
caption = ARGV[1]

def find_element_or_wait d, xp, s = (0.3..1)
  e = nil
  while not e
    begin
      e = d.find_element(:xpath, xp)
    rescue Selenium::WebDriver::Error::NoSuchElementError => er
      sleep 0.3
    end
  end
  sleep rand(s)
  e
end

args = [
'--window-size=240,580',
'--user-data-dir=./chromium',
'--user-agent=Mozilla/5.0 (Linux; Android 6.0; Nexus 5 Build/MRA58N) AppleWebKit/537.36 (KHTML, like Gecko) Chrome/63.0.3239.84 Mobile Safari/537.36']

options = Selenium::WebDriver::Chrome::Options.new(args: args)

driver = Selenium::WebDriver.for(:chrome, options: options)

driver.get('https://instagram.com')

if ARGV[2] == '-d'
  $stdin.gets
  driver.quit
  exit
end

sleep 3
img_btn = find_element_or_wait(driver, '//*[@id="react-root"]/section/nav[2]/div/div/div[2]/div/div/div[3]', 0)
form = find_element_or_wait(driver, '//*[@id="react-root"]/section/nav[2]/div/div/form/input', 0)

img_btn.click
form.send_keys(File.absolute_path img)

scale_btn = find_element_or_wait(driver, '//*[@id="react-root"]/div/div[2]/div[2]/div/div/div/button[1]', (1.5..2))
scale_btn.click

next_btn = find_element_or_wait(driver, '//*[@id="react-root"]/div/div[1]/header/div[2]/button')
next_btn.click

tχt_area = find_element_or_wait(driver, '//*[@id="react-root"]/div/div[2]/section[1]/div/textarea', (1..1.5))
tχt_area.click
tχt_area.send_keys(caption)

share_btn = find_element_or_wait(driver, '//*[@id="react-root"]/div/div[1]/header/div[2]/button')
share_btn.click

img_btn = find_element_or_wait(driver, '//*[@id="react-root"]/section/nav[2]/div/div/div[2]/div/div/div[3]', 0)
sleep rand(0.3..1)

driver.quit
