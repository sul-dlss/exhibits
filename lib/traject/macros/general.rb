# frozen_string_literal: true
module Macros
  # General helpers for any traject mappings, stolen originally from DLME
  module General
    def accumulate(&lambda)
      lambda do |record, accumulator, context|
        Array(lambda.call(record, context)).each do |v|
          accumulator << v if v.present?
        end
      end
    end

    # only accumulate values if a condition is met
    def conditional(condition, lambda)
      lambda do |record, accumulator, context|
        if condition.call(record, context)
          lambda.call(record, accumulator, context)
        end
      end
    end

    # try a bunch of macros and short-circuit after one returns values
    def first(*macros)
      lambda do |record, accumulator, context|
        macros.lazy.map do |lambda|
          lambda.call(record, accumulator, context)
        end.reject(&:blank?).first
      end
    end

    def from_settings(field)
      lambda do |_record, accumulator, context|
        accumulator << context.settings.fetch(field)
      end
    end

    def copy(field)
      lambda do |_record, accumulator, context|
        Array(context.output_hash[field]).each do |v|
          accumulator << v
        end
      end
    end

    # apply the same mapping to multiple fields
    def to_fields(fields, mapping_method)
      fields.each { |field| to_field field, mapping_method }
    end

    # construct a structured hash using values extracted using traject
    def transform_values(context, hash)
      hash.transform_values do |lambdas|
        accumulator = []
        Array(lambdas).each do |lambda|
          lambda.call(context.source_record, accumulator, context)
        end
        accumulator
      end
    end
  end
end
