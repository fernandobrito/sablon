module Sablon
  module Processor
    # Keep track of highest id in order to add unique
    # ids when iterating on loops
    class IdTracker
      def initialize
        @highest_id = 0
      end

      # look for the docPr or cNvPr element with the highest id
      def find_highest_id(zip_contents)
        zip_contents.each do |entry_name, content|
          content = Nokogiri::XML(content)
          ids = content.search(".//*[local-name() = 'docPr']/@id | .//*[local-name() = 'cNvPr']/@id")

          next unless ids.any?

          highest_id = ids.map{ |attr| attr.value.to_i }.max
          @highest_id = [highest_id, @highest_id].max
        end
      end

      def update_ids(content)
        elements_with_id = content.search(".//*[local-name() = 'docPr'] | .//*[local-name() = 'cNvPr']")
        # Word generates cNvPr inside docPr with same ids
        # Grouping elements by id ensures we give the same new id to both
        grouped_elements = elements_with_id.group_by { |element| element['id'] }
        grouped_elements.each do |_, elements|
          new_id = next_id
          elements.each { |element| element['id'] = new_id }
        end
      end

      def next_id
        @highest_id += 1
      end
    end
  end
end