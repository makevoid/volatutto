module FormHelpers
  def form(object, options, &block)
    @_form_name = options[:name]
    @_object = object
    options[:id] = options[:name] if options[:id].blank?
    
    haml_tag :form, options do 
      block.call
    end
  end
  
  def tfield(name, label="")
    label name, label
    haml_tag :input, name: name, id: "#{@_form_name}_name", value: @_object[name.to_sym]
  end
  
  def submit(label)
    haml_tag :input, value: label, class: "submit", type: "submit"
  end
  
  def select(name, collection, label="", options={})
    label name, label, options
    haml_tag :select, options.merge(name: name) do
      collection.each do |elem|
        optz = {}
        optz = optz.merge(selected: "selected") if @_object[name.to_sym] == elem
        haml_tag :option, optz do
          haml_concat elem
        end
      end
    end
  end
  
  def label(name, string, options={})
    haml_tag :label, options.merge(for: "#{@_form_name}_#{name}") do
      haml_concat string
    end unless string.blank?
  end
  
  def spinner
    haml_tag :div, id: "spinner" do
      image_tag "/imgs/spinner.gif"
    end
  end
end