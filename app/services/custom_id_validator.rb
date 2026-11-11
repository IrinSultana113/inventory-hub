
class CustomIdValidator
  def initialize(inventory, custom_id)
    @inventory = inventory
    @custom_id = custom_id.to_s
  end

  def valid?
    format_elements = @inventory.custom_id_format.presence ||
                      Inventory.new.custom_id_format

    pattern = format_elements.map do |element|
      pattern_for(element)
    end.join

    if @custom_id.match?(/\A#{pattern}\z/)
      true
    else
      false
    end
  end

  private

  def pattern_for(element)
    case element["type"]
    when "fixed_text"
      Regexp.escape(element["value"].to_s)

    when "sequence"
      number_pattern(element.fetch("format", "D4"), unlimited: true)

    when "random_20bit"
      number_pattern(element.fetch("format", "D7"),
                     max_decimal_length: 7,
                     max_hex_length: 5)

    when "random_32bit"
      number_pattern(element.fetch("format", "D10"),
                     max_decimal_length: 10,
                     max_hex_length: 8)

    when "random_6_digit"
      number_pattern(element.fetch("format", "D6"),
                     max_decimal_length: 6,
                     max_hex_length: 5)

    when "random_9_digit"
      number_pattern(element.fetch("format", "D9"),
                     max_decimal_length: 9,
                     max_hex_length: 8)

    when "guid"
      "[0-9a-f]{8}-[0-9a-f]{4}-[0-9a-f]{4}-[0-9a-f]{4}-[0-9a-f]{12}"

    when "date"
      "[0-9]{8}"

    when "time"
      "[0-9]{6}"

    else
      raise ArgumentError, "Unsupported ID element"
    end
  end

  def number_pattern(format, unlimited: false,
                     max_decimal_length: nil, max_hex_length: nil)
    format_type = format.to_s[0]
    length = format.to_s[1..].to_i

    unless ["D", "X"].include?(format_type) && length.positive?
      raise ArgumentError, "Invalid number format"
    end

    characters = format_type == "X" ? "0-9A-F" : "0-9"

    if unlimited
      "[#{characters}]{#{length},}"
    else
      natural_max_length =
        if format_type == "X"
          max_hex_length
        else
          max_decimal_length
        end

      maximum_length = [natural_max_length, length].max

      "[#{characters}]{#{length},#{maximum_length}}"
    end
  end
end
