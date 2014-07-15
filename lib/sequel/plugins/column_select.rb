module Sequel
  module Plugins
    # The column_select plugin changes the default selection for a
    # model dataset to explicit select all columns from the table:
    # <tt>table.column1, table.column2, table.column3, ...</tt>.
    # This makes it simpler to add columns to the model's table
    # in a migration concurrently while running the application,
    # without it affecting the operation of the application.
    #
    # Usage:
    #
    #   # Make all model subclasses explicitly select qualified columns
    #   Sequel::Model.plugin :column_select
    #
    #   # Make the Album class select qualified columns
    #   Album.plugin :column_select
    module ColumnSelect
      # Modify the current model's dataset selection, if the model
      # has a dataset.
      def self.configure(model)
        model.instance_eval do
          self.dataset = dataset if @dataset
        end
      end

      module ClassMethods
        private

        # If the underlying dataset selects from a single table and
        # has no explicit selection, explicitly select all columns from that table,
        # qualifying them with table's name.
        def convert_input_dataset(ds)
          ds = super
          if !ds.opts[:select] && (from = ds.opts[:from]) && from.length == 1 && !ds.opts[:join]
            ds = ds.select(*ds.columns.map{|c| Sequel.qualify(ds.first_source, Sequel.identifier(c))})
          end
          ds
        end
      end
    end
  end
end
