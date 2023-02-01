# Importing the required files
require_relative "./itinerary_parser.rb"

parse_itinerary_from_file("./samples/query_sample_one.txt", "results/query_sample_one.json")
parse_itinerary_from_file("./samples/query_sample_two.txt", "results/query_sample_two.json")
parse_itinerary_from_file("./samples/query_sample_three.txt", "results/query_sample_three.json")
parse_itinerary_from_file("./samples/query_sample_four.txt", "results/query_sample_four.json")
