def load_config(file_path, overrides=[])
  overrides = overrides.map{|override| override.to_s}

  data = File.new(file_path, "r")

  config = {}
  group = ""
  attributes = {}

  data.each_line do |line|
    unless /^(\s*)\[(\w+)\](\s*)$/i.match(line).nil?
      group = line.scan(/\w+/).join(' ')
      attributes = {}
    else
      line.scan /^(\w+)(\<(\w)+\>){0,1}\ = (\"){0,1}([a-zA-Z0-9\/,\s]+)(\"){0,1}(\s*)((\;)(.*)){0,1}$/i do | attribute, override, suffix, s1, value|
        value = value.strip
        if value =~ /^((\w+),)+(\w+)/i
          value = value.split ','
        end

        if !override.nil?
          override = override.gsub("<", "").gsub(">", "")
          if overrides.include? override
            attributes[attribute] = value
          end
        else
          attributes[attribute] = value
        end
      end
    end

    config[group] = OpenStruct.new(attributes)
  end

  data.close
  return OpenStruct.new(config)
end

CONFIG = load_config('settings.conf', ["ubuntu", :production])