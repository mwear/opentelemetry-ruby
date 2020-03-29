# frozen_string_literal: true

# Copyright 2020 OpenTelemetry Authors
#
# SPDX-License-Identifier: Apache-2.0

module OpenTelemetry
  class Context
    module Propagation
      # A no-op injector implementation
      class NoopInjector
        # Inject the given context into the specified carrier
        #
        # @param [Context] context The context to be injected
        # @param [Context] carrier The carrier to inject the provided context
        #   into
        # @param [optional Callable] setter An optional callable that takes a carrier and a key and
        #   a value and assigns the key-value pair in the carrier
        # @return [Object] carrier
        def inject(context, carrier, &setter)
          carrier
        end
      end
    end
  end
end
