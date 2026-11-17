
class CustomIdFormatValidator < ActiveModel::EachValidator
  ALLOWED_TYPES = %w[
    fixed_text sequence random_20bit random_32bit
    random_6_digit random_9_digit guid date time
  ].freeze

  NUMBER_TYPES = %w[
    sequence random_20bit random_32bit
    random_6_digit random_9_digit
  ].freeze

  def validate_each(record, attribute, value)
    return if value.blank? # default format will be used

    unless value.is_a?(Array) && value.length.between?(1, 10)
      record.errors.add(attribute, "must contain between 1 and 10 elements")
      return
    end

    value.each do |element|
      unless element.is_a?(Hash) && ALLOWED_TYPES.include?(element["type"])
        record.errors.add(attribute, "contains an invalid element")
        return
      end

      if element["type"] == "fixed_text"
        if element["value"].blank?
          record.errors.add(attribute, "fixed text cannot be blank")
          return
        end
      elsif NUMBER_TYPES.include?(element["type"])
        format = element["format"].to_s

        unless format.match?(/\A[DXdx][1-9]\d*\z/) && format[1..].to_i <= 20
          record.errors.add(attribute, "contains an invalid number format")
          return
        end
      end
    end
  end
end
