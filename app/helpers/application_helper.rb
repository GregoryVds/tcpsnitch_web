module ApplicationHelper
  def show_property(property, value, klass='col s6')
    capture_haml do
      haml_tag :div, class: klass do
        haml_tag :strong, property + ': '
        haml_tag :span, value
        haml_tag :br
      end
    end
  end

  def show_property_xl(property, value)
    show_property(property, value, '')
  end

  def show_properties(section_name, obj, properties)
    capture_haml do
      haml_tag :div, class: 'row' do
        haml_tag :h5, section_name
        properties.each do |prop|
          haml_concat show_property(prop.to_s.humanize, obj.send(prop))
        end
      end
    end
  end

  def active_on(controller, action)
    (params[:controller] == controller && params[:action] == action) ? 'active' : ''
  end
end
