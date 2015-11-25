//  This program is free software: you can redistribute it and/or modify
//  it under the terms of the GNU General Public License as published by
//  the Free Software Foundation, either version 3 of the License, or
//  (at your option) any later version.
//
//  This program is distributed in the hope that it will be useful,
//  but WITHOUT ANY WARRANTY; without even the implied warranty of
//  MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE.  See the
//  GNU General Public License for more details.
//
//  A copy of the GNU General Public License is available at <http://www.gnu.org/licenses/>.
//  

#include "OctoWS2811.h"
#include "Led.h"
#include "MavLinkData.h"
#include "MavConsole.h"

extern MavLinkData *mav;
extern MavConsole *console;
extern int displayMemory[];
extern int drawingMemory[];

Led::Led() {
  leds_on_strip = 8;

  leds = new OctoWS2811(8, displayMemory, drawingMemory, WS2811_GRB | WS2811_800kHz);
  leds->begin();

  for (int i=0; i < 8*8; i++) {
    leds->setPixel(i, 0x000000);
  }
  leds->show();
  
  LedPattern* led_pattern = new LedPattern((char*)"normal"); 
  LedStripState* strip_state = new LedStripState();
  strip_state->add_bulb(255, 0, 0);
  strip_state->add_bulbs(0, 0, 0, 6);
  strip_state->add_bulb(0, 255, 0);
  led_pattern->add_strip_state(strip_state);
  add_pattern(led_pattern);

  led_pattern = new LedPattern((char*)"all_off"); 
  strip_state = new LedStripState();
  strip_state->add_bulbs(0, 0, 0, 8);
  led_pattern->add_strip_state(strip_state);
  add_pattern(led_pattern);
  
  led_pattern = new LedPattern((char*)"landing1"); 
  strip_state = new LedStripState();
  strip_state->add_bulb(255, 0, 0);
  strip_state->add_bulbs(100, 100, 100, 6);
  strip_state->add_bulb(0, 255, 0);
  led_pattern->add_strip_state(strip_state); 
  add_pattern(led_pattern);
  
  // 0                    this are descending state sequences
  // 1 R             G    
  // 2 R-W         W-G
  // 3 R-W-W-    W-W-G
  // 4 R-W-W-W-W-W-W-G
  led_pattern = new LedPattern((char*)"landing2"); 

  strip_state = new LedStripState(1000);
  strip_state->add_bulb(255, 0, 0);
  strip_state->add_bulbs(0, 0, 0, 6);
  strip_state->add_bulb(0, 255, 0);
  led_pattern->add_strip_state(strip_state);  

  strip_state = new LedStripState(200);
  strip_state->add_bulb(255, 0, 0);
  strip_state->add_bulb(100, 100, 100);
  strip_state->add_bulbs(0, 0, 0, 4);
  strip_state->add_bulb(100, 100, 100);
  strip_state->add_bulb(0, 255, 0);
  led_pattern->add_strip_state(strip_state);  

  strip_state = new LedStripState(200);
  strip_state->add_bulb(255, 0, 0);
  strip_state->add_bulbs(100, 100, 100, 2);
  strip_state->add_bulbs(0, 0, 0, 2);
  strip_state->add_bulbs(100, 100, 100, 2);
  strip_state->add_bulb(0, 255, 0);
  led_pattern->add_strip_state(strip_state);
    
  strip_state = new LedStripState(200);
  strip_state->add_bulb(255, 0, 0);
  strip_state->add_bulbs(100, 100, 100, 6);
  strip_state->add_bulb(0, 255, 0);
  led_pattern->add_strip_state(strip_state);  
  add_pattern(led_pattern);

  led_pattern = new LedPattern((char*)"landing3"); 

  strip_state = new LedStripState(20);
  strip_state->add_bulb(255, 0, 0);
  strip_state->add_bulbs(0, 0, 0, 7);
  led_pattern->add_strip_state(strip_state);  

  strip_state = new LedStripState(20);
  strip_state->add_bulbs(0, 0, 0, 1);
  strip_state->add_bulb(255, 0, 0);
  strip_state->add_bulbs(0, 0, 0, 6);
  led_pattern->add_strip_state(strip_state);  
  
  strip_state = new LedStripState(20);
  strip_state->add_bulbs(0, 0, 0, 2);
  strip_state->add_bulb(255, 0, 0);
  strip_state->add_bulbs(0, 0, 0, 5);
  led_pattern->add_strip_state(strip_state); 
     
  strip_state = new LedStripState(20);
  strip_state->add_bulbs(0, 0, 0, 3);
  strip_state->add_bulb(255, 0, 0);
  strip_state->add_bulbs(0, 0, 0, 4);
  led_pattern->add_strip_state(strip_state);  
    
  strip_state = new LedStripState(20);
  strip_state->add_bulbs(0, 0, 0, 4);
  strip_state->add_bulb(255, 0, 0);
  strip_state->add_bulbs(0, 0, 0, 3);
  led_pattern->add_strip_state(strip_state); 
     
  strip_state = new LedStripState(20);
  strip_state->add_bulbs(0, 0, 0, 5);
  strip_state->add_bulb(255, 0, 0);
  strip_state->add_bulbs(0, 0, 0, 2);
  led_pattern->add_strip_state(strip_state); 
     
  strip_state = new LedStripState(20);
  strip_state->add_bulbs(0, 0, 0, 6);
  strip_state->add_bulb(255, 0, 0);
  strip_state->add_bulbs(0, 0, 0, 1);
  led_pattern->add_strip_state(strip_state);
      
  strip_state = new LedStripState(20);
  strip_state->add_bulbs(0, 0, 0, 7);
  strip_state->add_bulb(255, 0, 0);
  led_pattern->add_strip_state(strip_state);  

  add_pattern(led_pattern);
}

LedBulbState::LedBulbState(uint8_t red_param, uint8_t green_param, uint8_t blue_param) {
  red = red_param;
  green = green_param;
  blue = blue_param;
}

LedStripState::LedStripState() {
    state_time = LED_DEFAULT_STATE_TIME;
}

LedStripState::LedStripState(uint16_t time_param) {
  state_time = time_param;
}

void LedStripState::add_bulb(uint8_t red_param, uint8_t green_param, uint8_t blue_param) {
  if(bulb_count < LED_MAX_BULBS) {
    bulbs[bulb_count] = new LedBulbState(red_param, green_param, blue_param);
    bulb_count++;
  }
}

void LedStripState::add_bulbs(uint8_t red_param, uint8_t green_param, uint8_t blue_param, uint8_t count) {
  for(uint8_t i=0; i<count; i++) {
    add_bulb(red_param, green_param, blue_param);
  }
}

LedPattern::LedPattern(char* name_param) {
  pattern_name = name_param;
  strip_state_count = 0;
}

void LedPattern::add_strip_state(LedStripState* strip_state_param) {
  if(strip_state_count < LED_MAX_STRIP_STATES) {
    led_strip_states[strip_state_count] = strip_state_param;
    strip_state_count++;  
  }
}

void Led::add_pattern(LedPattern* pattern) {
  if(led_pattern_count < LED_MAX_PATTERNS) {
    led_patterns[led_pattern_count] = pattern;
    led_pattern_count++;
  }
}

void Led::show_pattern(uint8_t pattern_index, uint8_t reverse) {
  static int8_t previous_pattern_index = -1;
  static uint8_t current_state = 0;
  static uint32_t state_expiry_time = 0L;
  uint32_t current_milli = millis();
  LedStripState* strip_state;

  if(pattern_index >= led_pattern_count) {
    return;
  }
  LedPattern* pattern = led_patterns[pattern_index];     
  uint8_t do_init = pattern_index != previous_pattern_index;      
  if(do_init) {
    current_state = 0;
    state_expiry_time = 0L;
  }

  uint8_t do_state_change = pattern->strip_state_count > 1 && current_milli > state_expiry_time;
  if(do_init || do_state_change) {                           
    if(reverse) {
      strip_state = pattern->led_strip_states[pattern->strip_state_count - current_state - 1];      
    } else {
      strip_state = pattern->led_strip_states[current_state];       
    }

    for(uint8_t i=0; i<strip_state->bulb_count; i++) {
      for(uint8_t j=0; j<strip_state->bulb_count; j++) {
        LedBulbState* bulb_state = strip_state->bulbs[j];
        leds->setPixel(j+(i*8), bulb_state->red << 16 | bulb_state->green << 8 | bulb_state->blue);
      }
    }
    leds->show();
    current_state = ((current_state + 1) % pattern->strip_state_count);
    state_expiry_time = current_milli + pattern->led_strip_states[current_state]->state_time;
  }
  previous_pattern_index = pattern_index;
}

void Led::process_10_millisecond() {
  int8_t pattern_index = 0;
  uint8_t reverse = 0;
  
  if(mav->rc8 < 1050) {
    pattern_index = 0;
  } else if(mav->rc8 >= 1050 && mav->rc8 < 1150) {                             
    pattern_index = 1;
  } else if(mav->rc8 >= 1150 && mav->rc8 < 1250) {
    pattern_index = 2;
  } else if(mav->rc8 >= 1250) {
    pattern_index = 3;
    if(mav->climb_rate < 0) {
      reverse = 1;
    }
  }
//pattern_index = 4;  
  show_pattern(pattern_index, reverse);
}




  

