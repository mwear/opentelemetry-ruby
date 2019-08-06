# frozen_string_literal: true

# Copyright 2019 OpenTelemetry Authors
#
# SPDX-License-Identifier: Apache-2.0

require 'test_helper'

describe OpenTelemetry::Instrumentation do
  class TestInstrumentation < OpenTelemetry::Instrumentation
    instrumentation_name :otel_test_instrumentation
  end

  describe '.new' do
    it 'is private' do
      -> { TestInstrumentation.new }.must_raise(NoMethodError)
    end
  end

  describe '.instance' do
    it 'returns an instance of instrumentation class' do
      TestInstrumentation.instance.must_be_instance_of(TestInstrumentation)
    end
  end

  describe '.instrumentation_name' do
    it 'returns instrumentation name' do
      TestInstrumentation.instance.instrumentation_name.must_equal(:otel_test_instrumentation)
    end
  end
end
