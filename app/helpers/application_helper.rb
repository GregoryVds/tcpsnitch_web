module ApplicationHelper
	def show_property(property, value)
		capture_haml do
			haml_tag :p do
				haml_tag :strong, property + ': '
				haml_tag :span, value
			end
		end
	end
end
