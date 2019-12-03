# frozen_string_literal: true

# Copyright 2019 OpenTelemetry Authors
#
# SPDX-License-Identifier: Apache-2.0

module OpenTelemetry
  class Context
    module Propagation
      # The Propagation class provides methods to inject and extract context
      # to pass across process boundaries
      class Propagation
        EMPTY_ARRAY = [].freeze
        private_constant :EMPTY_ARRAY

        # Injects context into carrier to be propagated across process
        # boundaries
        #
        # @param [Context] context Context to be injected into carrier
        # @param [Object] carrier A carrier of HTTP headers to inject
        #   context into
        # @param [Array<Object>] http_injectors An array of HTTP injectors. Each
        #   injector will be invoked once with given context and carrier
        #
        # @return [Object] carrier
        def inject(context, carrier, http_injectors = EMPTY_ARRAY)
          http_injectors.inject(carrier) do |memo, injector|
            injector.inject(context, memo)
          end
        end

        # Extracts context from a carrier
        #
        # @param [Context] context Context to be updated with the state
        #   extracted from the carrier
        # @param [Object] carrier A carrier of HTTP headers to extract context
        #   from
        # @param [Array<Object>] http_extractors An array of HTTP extractors.
        #   Each extractor will be invoked once with given context and carrier
        #
        # @return [Context] a new context updated with state extracted from the
        #   carrier
        def extract(context, carrier, http_extractors = EMPTY_ARRAY)
          http_extractors.inject(context) do |ctx, extractor|
            extractor.extract(ctx, carrier)
          end
        end
      end
    end
  end
end