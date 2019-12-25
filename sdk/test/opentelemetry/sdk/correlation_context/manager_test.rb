# frozen_string_literal: true

# Copyright 2019 OpenTelemetry Authors
#
# SPDX-License-Identifier: Apache-2.0

require 'test_helper'

describe OpenTelemetry::SDK::CorrelationContext::Manager do
  Context = OpenTelemetry::Context
  let(:manager) { OpenTelemetry::SDK::CorrelationContext::Manager.new }

  after do
    Context.clear
  end

  describe '.set_value' do
    describe 'explicit context' do
      it 'sets key/value in context' do
        ctx = Context.empty
        _(manager.value('foo', context: ctx)).must_be_nil

        ctx2 = manager.set_value('foo', 'bar', context: ctx)
        _(manager.value('foo', context: ctx2)).must_equal('bar')

        _(manager.value('foo', context: ctx)).must_be_nil
      end
    end

    describe 'implicit context' do
      it 'sets key/value in implicit context' do
        _(manager.value('foo')).must_be_nil

        Context.with_current(manager.set_value('foo', 'bar')) do
          _(manager.value('foo')).must_equal('bar')
        end

        _(manager.value('foo')).must_be_nil
      end
    end

    it 'coerces values to strings' do
      ctx = manager.set_value('k1', 1)
      ctx = manager.set_value('k2', true, context: ctx)

      Context.with_current(ctx) do
        _(manager.value('k1')).must_equal('1')
        _(manager.value('k2')).must_equal('true')
      end
    end
  end

  describe '.clear' do
    describe 'explicit context' do
      it 'returns context with empty correlation context' do
        ctx = manager.set_value('foo', 'bar', context: Context.empty)
        _(manager.value('foo', context: ctx)).must_equal('bar')

        ctx2 = manager.clear(context: ctx)
        _(manager.value('foo', context: ctx2)).must_be_nil
      end
    end

    describe 'implicit context' do
      it 'returns context with empty correlation context' do
        ctx = manager.set_value('foo', 'bar')
        _(manager.value('foo', context: ctx)).must_equal('bar')

        ctx2 = manager.clear
        _(manager.value('foo', context: ctx2)).must_be_nil
      end
    end
  end

  describe '.remove_value' do
    describe 'explicit context' do
      it 'returns context with key removed from correlation context' do
        ctx = manager.set_value('foo', 'bar', context: Context.empty)
        _(manager.value('foo', context: ctx)).must_equal('bar')

        ctx2 = manager.remove_value('foo', context: ctx)
        _(manager.value('foo', context: ctx2)).must_be_nil
      end

      it 'returns same context if key does not exist' do
        ctx = manager.set_value('foo', 'bar', context: Context.empty)
        _(manager.value('foo', context: ctx)).must_equal('bar')

        ctx2 = manager.remove_value('nonexistant-key', context: ctx)
        _(ctx2).must_equal(ctx)
      end
    end

    describe 'implicit context' do
      it 'returns context with key removed from correlation context' do
        Context.with_current(manager.set_value('foo', 'bar')) do
          _(manager.value('foo')).must_equal('bar')

          ctx = manager.remove_value('foo')
          _(manager.value('foo', context: ctx)).must_be_nil
        end
      end

      it 'returns same context if key does not exist' do
        Context.with_current(manager.set_value('foo', 'bar')) do
          _(manager.value('foo')).must_equal('bar')
          ctx_before = OpenTelemetry::Context.current

          ctx = manager.remove_value('nonexistant-key')
          _(ctx).must_equal(ctx_before)
        end
      end
    end
  end

  describe '.build_context' do
    let(:initial_context) { manager.set_value('k1', 'v1') }

    describe 'explicit context' do
      it 'sets entries' do
        ctx = initial_context
        ctx = manager.build_context(context: ctx) do |correlations|
          correlations.set_value('k2', 'v2')
          correlations.set_value('k3', 'v3')
        end
        _(manager.value('k1', context: ctx)).must_equal('v1')
        _(manager.value('k2', context: ctx)).must_equal('v2')
        _(manager.value('k3', context: ctx)).must_equal('v3')
      end

      it 'removes entries' do
        ctx = initial_context
        ctx = manager.build_context(context: ctx) do |correlations|
          correlations.remove_value('k1')
          correlations.set_value('k2', 'v2')
        end
        _(manager.value('k1', context: ctx)).must_be_nil
        _(manager.value('k2', context: ctx)).must_equal('v2')
      end

      it 'clears entries' do
        ctx = initial_context
        ctx = manager.build_context(context: ctx) do |correlations|
          correlations.clear
          correlations.set_value('k2', 'v2')
        end
        _(manager.value('k1', context: ctx)).must_be_nil
        _(manager.value('k2', context: ctx)).must_equal('v2')
      end
    end

    describe 'implicit context' do
      it 'sets entries' do
        Context.with_current(initial_context) do
          ctx = manager.build_context do |correlations|
            correlations.set_value('k2', 'v2')
            correlations.set_value('k3', 'v3')
          end
          Context.with_current(ctx) do
            _(manager.value('k1')).must_equal('v1')
            _(manager.value('k2')).must_equal('v2')
            _(manager.value('k3')).must_equal('v3')
          end
        end
      end

      it 'removes entries' do
        Context.with_current(initial_context) do
          _(manager.value('k1')).must_equal('v1')

          ctx = manager.build_context do |correlations|
            correlations.remove_value('k1')
            correlations.set_value('k2', 'v2')
          end

          Context.with_current(ctx) do
            _(manager.value('k1')).must_be_nil
            _(manager.value('k2')).must_equal('v2')
          end
        end
      end

      it 'clears entries' do
        Context.with_current(initial_context) do
          _(manager.value('k1')).must_equal('v1')

          ctx = manager.build_context do |correlations|
            correlations.clear
            correlations.set_value('k2', 'v2')
          end

          Context.with_current(ctx) do
            _(manager.value('k1')).must_be_nil
            _(manager.value('k2')).must_equal('v2')
          end
        end
      end
    end
  end
end
