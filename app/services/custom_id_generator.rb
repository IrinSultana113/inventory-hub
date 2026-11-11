require "securerandom"

class CustomIdGenerator
  def initialize(inventory, sequence_number: nil)
    @inventory = inventory
    @sequence_number = sequence_number ||
                       inventory.items.maximum(:sequence_number).to_i + 1
  end

  def generate
    format_elements = get_format_elements

    format_elements.map do |element|
      generate_element(element)
    end.join
  end

  private

  def get_format_elements
    @inventory.custom_id_format.presence ||
      Inventory.new.custom_id_format
  end

  def generate_element(element)
    case element["type"]
    when "fixed_text"
      element["value"].to_s
    when "sequence"
      generate_sequence(element)
    when "random_20bit"
      generate_20bit_random(element)
    when "random_32bit"
      generate_32bit_random(element)
    when "random_6_digit"
      generate_6_digit_random(element)
    when "random_9_digit"
      generate_9_digit_random(element)
    when "guid"
      generate_guid
    when "date"
      generate_date
    when "time"
      generate_time
    else
      raise ArgumentError, "Unsupported ID element: #{element["type"]}"
    end
  end
  
  def format_number(number, format)
    format_type = format.to_s.first
    length = format.to_s[1..-1].to_i

    formatted_number =
      if format_type == "X"
        number.to_i.to_s(16).upcase
      else
        number.to_i.to_s
      end

    formatted_number.rjust(length, "0")
  end  

  def generate_sequence(element)
    format = element.fetch("format", "D4")
    format_number(@sequence_number, format)
  end

  def generate_20bit_random(element)
    number = SecureRandom.random_number(2**20)
    format_number(number, element.fetch("format", "D7"))
  end

  def generate_32bit_random(element)
    number = SecureRandom.random_number(2**32)
    format_number(number, element.fetch("format", "D10"))
  end

  def generate_6_digit_random(element)
    number = SecureRandom.random_number(1_000_000)
    format_number(number, element.fetch("format", "D6"))
  end

  def generate_9_digit_random(element)
    number = SecureRandom.random_number(1_000_000_000)
    format_number(number, element.fetch("format", "D9"))
  end

  def generate_guid
    SecureRandom.uuid
  end

  def generate_date
    Time.current.strftime("%Y%m%d")
  end

  def generate_time
    Time.current.strftime("%H%M%S")
  end
end