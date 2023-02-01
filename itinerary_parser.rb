# Importing the required libaries
require "json"

# Constants
DESTINATION_KEYWORDS = ["arrive in", "drive to", "drive back to", "stay in", "fly to", "train to",
                        "bus to",
                        "taxi to", "back to", "return to", "return from", "return",
                        "arrive back in", "arrive back from", "arrive back"]

ATTRACTION_KEYWORDS = ["visit", "including", "visit the", "explore the", "on", "at", "Take a tour of"]

ACTIVITY_KEYWORDS = [
  "boat ride",
  "camel safari",
  "jeep safari",
  "Enjoy",
  "Perform",
  "bungy jumping",
  "rock climbing",
  "paragliding",
  "parasailing",
  "rafting",
  "trekking",
  "hiking",
  "mountain biking",
  "cycling",
  "skiing",
  "snowboarding",
  "snowmobiling",
  "river rafting",
  "canoeing",
  "rafting trip",
  "canal cruise",
  "rickshaw ride",
]

# Function that parses the query string and returns the destinations, attractions and activities
def itinerary_parser(query_string)
  # downcase the query string
  query_string = query_string.downcase

  results = {}

  day_number = get_day_number(query_string)
  if day_number != -1
    results[:day] = day_number
  end

  city_name = get_city_name(query_string)
  attractions = cleanup_array_elements(get_attractions(query_string))
  activities = cleanup_array_elements(get_activities(query_string))

  results = results.merge({ :destination => city_name })
  results = results.merge({ :attractions => attractions })
  results = results.merge({ :activities => activities })

  results
end

# Function to add missing cities to the results
# if a city is missing, insert the city that was last found
# Fails if the first city is missing
def add_missing_cities(results)
  index_counter = results.length - 1

  # Loop in reverse order
  # If a city is missing, add the last city
  while index_counter >= 0
    if !results[index_counter].has_key?(:destination) || results[index_counter][:destination] == ""
      results[index_counter][:destination] = get_first_city(results, index_counter)
    end

    index_counter -= 1
  end

  results
end

# Function to cleanup elements in an array
# i.e, if a word starts with 'and', then remove it
def cleanup_array_elements(array)
  new_array = array.map do |element|
    if element.start_with?("and ")
      element = element[4..-1]
    end

    element
  end

  new_array
end

# Function to get first city while iterating reverse
def get_first_city(results, from)
  if from <= 0
    return ""
  end

  while from >= 0
    if results[from].has_key?(:destination)
      if results[from][:destination] != ""
        return results[from][:destination]
      end
    end

    from -= 1
  end

  ""
end

# Function to parse itinerary from a text file
# also writes the result to a json file
def parse_itinerary_from_file(file_path, save_file_path = "results.json")
  # Read the query string from the file
  query_string = File.read(file_path)
  query_line = ""
  day_count = 1
  result = []

  # get parsed information for each line
  query_string.each_line do |line|
    if line.length > 0 && line != "\n"
      query_line += line + " "
    elsif line == "\n"
      parsed_data = itinerary_parser(query_line)

      if !parsed_data.has_key?(:day)
        parsed_data[:day] = day_count
      end
      result.push(parsed_data)
      day_count += 1
      query_line = ""
    end
  end

  if query_line != ""
    parsed_data = itinerary_parser(query_line)

    if !parsed_data.has_key?(:day)
      parsed_data[:day] = day_count
    end
    result.push(parsed_data)
  end

  # add missing cities
  result = add_missing_cities(result)

  # write the result to the file
  File.open(save_file_path, "w") do |f|
    f.write(JSON.pretty_generate(result))
  end
end

# Function to get day from the query string
# For Example - Day 15: Arrive in Delhi
# So day = 15 in this case
def get_day_number(query_string)
  day = -1
  day_index = query_string.index("day")
  ordinal_format_number = extract_ordinal_number(query_string)
  ordinal_format_number_from_word = extract_ordinal_number_from_worded_ordinal(query_string)

  if ordinal_format_number != nil
    if is_valid_day_number(ordinal_format_number) == false
      day = -1
    else
      day = ordinal_format_number
    end
  elsif ordinal_format_number_from_word != nil
    if is_valid_day_number(ordinal_format_number_from_word) == false
      day = -1
    else
      day = ordinal_format_number_from_word
    end
  elsif day_index != nil
    day_index += 4

    # day constructor
    day_constructor = ""

    # loop till a character is not a number
    while true && day_index < query_string.length
      if query_string[day_index] == " "
        break
      else
        day_constructor += query_string[day_index]
      end

      day_index += 1
    end

    day = day_constructor.to_i
  end

  day
end

# Function to get the city name from the query string
# If a destination keyword is found, it will return the city name
# by skipping the keyword and the next word after it
def get_city_name(query_string)
  # Constants
  stoppers = {
    "arrive in" => ["and"],
    "drive to" => ["and"],
    "stay in" => ["and"],
    "fly to" => ["and"],
    "take a train to" => ["and"],
    "explore" => ["further"],
    "back to" => ["for", "and"],
    "return to" => ["for", "and"],
    "drive back to" => ["for", "and"],
  }

  city_name = ""
  destination_index = -1
  destination_keyword = ""

  # Find a keyword index if exists
  DESTINATION_KEYWORDS.each do |keyword|
    key_index = query_string.index(keyword)
    if key_index != nil
      destination_index = key_index
      destination_keyword = keyword
    end

    break if destination_index != -1
  end

  # if keyword exists
  if destination_index != -1
    # skip one index after the keyword
    destination_index += destination_keyword.length + 1

    # city constructor
    city_constructor = ""

    # loop through the query string, till the end or till the keyword "and"
    while true && destination_index < query_string.length
      if query_string[destination_index] == " "
        if stoppers.has_key?(destination_keyword) && stoppers[destination_keyword].include?(city_constructor)
          break
        end

        city_name += city_constructor + " "
        city_constructor = ""
      else
        city_constructor += query_string[destination_index]
      end
      destination_index += 1
    end

    if stoppers.has_key?(destination_keyword) && !stoppers[destination_keyword].include?(city_constructor)
      city_name += city_constructor
    end

    city_name = city_name[0..-2]
  end

  city_name
end

# Function to get the attractions from the query string
# If a attraction keyword is found, it will return the attractions
# by looping till a full stop is found
def get_attractions(query_string)
  attractions = []
  attraction_index = -1
  attraction_keyword = ""

  # Find a keyword index if exists
  ATTRACTION_KEYWORDS.each do |keyword|
    key_index = query_string.index(keyword)

    if key_index != nil
      attraction_index = key_index
      attraction_keyword = keyword
    end

    break if attraction_index != -1
  end

  if attraction_index != -1
    attraction_index += attraction_keyword.length + 1

    # attraction constructor
    attraction_constructor = ""

    # Loop through the string and stop when a full stop is found
    # or when the string ends
    # keep on adding the characters to the attraction_constructor
    # if a comma is found, add the attraction_constructor to the attractions array and clear the temp word
    while true && attraction_index < query_string.length
      if query_string[attraction_index] == ","
        attractions.push(attraction_constructor)
        attraction_constructor = ""
        attraction_index += 1
      elsif query_string[attraction_index] == " "
        if is_and_next(query_string, attraction_index)
          attractions.push(attraction_constructor)
          attraction_constructor = ""
          attraction_index += 4
        else
          attraction_constructor += query_string[attraction_index]
        end
      elsif query_string[attraction_index] == "."
        attractions.push(attraction_constructor)
        break
      else
        attraction_constructor += query_string[attraction_index]
      end
      attraction_index += 1
    end
  else
    return attractions
  end

  # This recursive call will get the attractions from the remaining string (if any)
  return attractions + get_attractions(query_string[attraction_index..-1])
end

# Function to get activities from the query string
# Find all the activities that are present in the query string
# Activities will be found by looping through the ACTIVITY_KEYWORDS
def get_activities(query_string)
  activities = []

  # Loop through the ACTIVITY_KEYWORDS
  ACTIVITY_KEYWORDS.each do |activity|
    key_index = query_string.index(activity)

    # If the activity is found, add it to the activities array
    if key_index != nil
      activities.push(activity)
    end
  end

  activities
end

# Function to check if next word is 'and'
def is_and_next(query_string, start_index)
  if start_index + 3 < query_string.length
    return query_string[start_index..start_index + 3] == " and"
  end

  false
end

# Function to get ordinal number from a string if it is present
def extract_ordinal_number(str)
  match = str.match(/(\d+)(?:st|nd|rd|th)/i)
  match ? match[1].to_i : nil
end

# Function to extract worded ordinal numbers from a string
# Limits to day = 20
def extract_ordinal_number_from_worded_ordinal(str)
  ordinal_words = %w[first second third fourth fifth sixth seventh eighth ninth tenth eleventh twelfth thirteenth fourteenth fifteenth sixteenth seventeenth eighteenth nineteenth twentieth]
  ordinal_word_to_count_hash = Hash[ordinal_words.map.with_index(1).to_a]

  splitted_words = str.downcase.split(" ")

  splitted_words.each_with_index do |word, index|
    if ordinal_word_to_count_hash.include? word

      # Check if the next word is 'day'
      if index + 1 < splitted_words.length && splitted_words[index + 1].start_with?("day")
        return ordinal_word_to_count_hash[word]
      end
    end
  end

  nil
end

# Function to check if a returned day is valid or not
def is_valid_day_number(day_number)
  day_number >= 1 && day_number <= 31
end
