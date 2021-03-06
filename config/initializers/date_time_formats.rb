Date::DATE_FORMATS[:month_and_year] = "%b %y"
Date::DATE_FORMATS[:de] = "%d.%m.%y"
Date::DATE_FORMATS[:long_de] = "%d.%m.%Y"
Date::DATE_FORMATS[:bill] = "%Y-%m"
Time::DATE_FORMATS[:de] = "%d.%m.%Y %H:%M:%S"

# patch Date._parse to accept DE format dates. This is used by ActiveRecord parsing of incoming form fields
# See http://stackoverflow.com/a/8841647/822904
class Date
  class << self
    def _parse_with_de_format(date, *args)
      if date =~ %r{(\d+)\.(\d+)\.(\d+)}
        year = $3.to_i
        # pick the correct century. code matches jquery-ui version
        if year < 100
          short_year_cutoff = (Date.current.year % 100) + 10
          year += Date.current.year - (Date.current.year % 100) + (year <= short_year_cutoff ? 0 : -100)
        end
        _parse_without_de_format("#{year}-#{$2}-#{$1}", *args)
      else
        _parse_without_de_format(date, *args)
      end
    end
    alias_method_chain :_parse, :de_format
  end
end
