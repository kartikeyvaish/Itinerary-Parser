# Itinerary-Parser

Parses Day wise Itinerary

### Usage

To parse a Itinerary, run the following command:

    $ ruby runner.rb

### Requirements

- Input Text File (Example - `input.txt` which contains the Itinerary)
- Output Text File (Example - `output.txt/json` which contains the parsed Itinerary)

Make sure to pass these two parameters in the `parse_itinerary_from_file` function `runner.rb` file.

Make sure `Ruby` is installed on your system.

### Output

Here are some outputs

#### Example 1:

```txt
Day 1: Arrive in Jaipur and visit Amber Fort, City Palace and Jantar Mantar.
```

```json
{
  "day": 1,
  "destination": "jaipur",
  "attractions": ["amber fort", "city palace", "jantar mantar"],
  "activities": []
}
```

#### Example 2:

```txt
Day 6: Drive to Jodhpur and visit Mehrangarh Fort, Jaswant Thada Memorial, and the Umaid Bhawan Palace.
```

```json
{
  "day": 6,
  "destination": "jodhpur",
  "attractions": [
    "mehrangarh fort",
    "jaswant thada memorial",
    "the umaid bhawan palace"
  ],
  "activities": []
}
```

#### Example 3:

```txt
Drive to Udaipur and visit the City Palace, Jagdish Temple, and the Monsoon Palace.

Take a boat ride on Lake Pichola and visit Jagmandir Island Palace and the Sajjangarh Wildlife Sanctuary.
```

```json
[
  {
    "destination": "udaipur",
    "attractions": ["the city palace", "jagdish temple", "the monsoon palace"],
    "activities": [],
    "day": 1
  },
  {
    "destination": "udaipur",
    "attractions": [
      "jagmandir island palace",
      "the sajjangarh wildlife sanctuary"
    ],
    "activities": ["boat ride"],
    "day": 2
  }
]
```

#### Example 4:

```txt
On the 3rd day, I want to Drive to Agra and visit the Taj Mahal, Agra Fort, and Itmad-ud-Daula.

On the fourth day, Drive to Jaipur and visit Amber Fort, City Palace, and Jantar Mantar.

Day 5: Explore Jaipur further, including Hawa Mahal, Jal Mahal and Birla Temple.
```

```json
[
  {
    "day": 3,
    "destination": "agra",
    "attractions": ["the taj mahal", "agra fort", "itmad-ud-daula"],
    "activities": []
  },
  {
    "day": 4,
    "destination": "jaipur",
    "attractions": ["amber fort", "city palace", "jantar mantar"],
    "activities": []
  },
  {
    "day": 5,
    "destination": "jaipur",
    "attractions": ["hawa mahal", "jal mahal", "birla temple"],
    "activities": []
  }
]
```
