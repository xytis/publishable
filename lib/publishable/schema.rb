module Publishable
  module Schema

    def load_schema!
      super

      class_eval do
        options = @publishable_options
        column_name = (options[:on] || :published).to_sym

        # silently ignore a missing column - since bombing on a missing column can make re-running migrations very hard
        return unless self.columns_hash[column_name.to_s].present?
        column_type = self.columns_hash[column_name.to_s].type

        if respond_to?(:scope)
          # define published/unpublished scope
          case column_type
          when :date
            scope :published, lambda { |*args|
              on_date = args[0] || Date.current
              where(arel_table[column_name].not_eq(nil)).where(arel_table[column_name].lteq(on_date))
            }

            scope :unpublished, lambda { |*args|
              on_date = args[0] || Date.current
              where(arel_table[column_name].not_eq(nil)).where(arel_table[column_name].gt(on_date))
            }

          when :datetime
            scope :published, lambda { |*args|
              at_time = args[0] || Time.now
              where(arel_table[column_name].not_eq(nil)).where(arel_table[column_name].lteq(at_time.utc))
            }

            scope :unpublished, lambda { |*args|
              at_time = args[0] || Time.now
              where(arel_table[column_name].not_eq(nil)).where(arel_table[column_name].gt(at_time.utc))
            }

          when :boolean
            scope :published, lambda {
              where(column_name => true)
            }

            scope :unpublished, lambda {
              where(column_name => false)
            }

          else
            raise ActiveRecord::ConfigurationError, "Invalid column_type #{column_type} for Publishable column on model #{self.name}"
          end

          # define recent/upcoming scopes
          if [:date, :datetime].include? column_type
            scope :recent, lambda { |*args|
              how_many = args[0] || nil
              col_name = arel_table[column_name].name
              published.limit(how_many).order("#{col_name} DESC")
            }
            scope :upcoming, lambda { |*args|
              how_many = args[0] || nil
              col_name = arel_table[column_name].name
              unpublished.limit(how_many).order("#{col_name} ASC")
            }
          end
        end

        case column_type
        when :datetime
          class_eval <<-EVIL, __FILE__, __LINE__ + 1
            def published?(_when = Time.now)
              #{column_name} ? #{column_name} <= _when : false
            end

            def unpublished?(_when = Time.now)
              !published?(_when)
            end

            def publish(_when = Time.now)
              self.#{column_name} = _when unless published?(_when)
            end

            def publish!(_when = Time.now)
              publish(_when)
              save if respond_to?(:save)
            end

            def unpublish()
              self.#{column_name} = nil
            end

            def unpublish!()
              unpublish()
              save if respond_to?(:save)
            end
          EVIL

        when :date
          class_eval <<-EVIL, __FILE__, __LINE__ + 1
            def published?(_when = Date.current)
              #{column_name} ? #{column_name} <= _when : false
            end

            def unpublished?(_when = Date.current)
              !published?(_when)
            end

            def publish(_when = Date.current)
              self.#{column_name} = _when unless published?(_when)
            end

            def publish!(_when = Date.current)
              publish(_when)
              save if respond_to?(:save)
            end

            def unpublish()
              self.#{column_name} = nil
            end

            def unpublish!()
              unpublish()
              save if respond_to?(:save)
            end
          EVIL

        when :boolean
          class_eval <<-EVIL, __FILE__, __LINE__ + 1
            def published?()
              #{column_name}
            end

            def unpublished?()
              !published?()
            end

            def publish()
              self.#{column_name} = true
            end

            def publish!()
              publish()
              save if respond_to?(:save)
            end

            def unpublish()
              self.#{column_name} = false
            end

            def unpublish!()
              unpublish()
              save if respond_to?(:save)
            end
          EVIL

        else
          raise ActiveRecord::ConfigurationError, "Invalid column_type #{column_type} for Publishable column on model #{self.name}"
        end
      end
    end
  end
end