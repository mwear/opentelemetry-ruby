# frozen_string_literal: true

# Copyright 2019 OpenTelemetry Authors
#
# SPDX-License-Identifier: Apache-2.0

require 'test_helper'

describe OpenTelemetry::Context do
  Context = OpenTelemetry::Context

  before do
    Context.current = nil
  end

  describe '.current' do
    it 'defaults to the root context' do
      _(Context.current).must_equal(Context::ROOT)
    end
  end

  describe '.with_current' do
    it 'handles nested contexts' do
      c1 = Context.new(nil, 'foo' => 'bar')
      Context.with_current(c1) do
        _(Context.current).must_equal(c1)
        c2 = Context.current.update('bar', 'baz')
        Context.with_current(c2) do
          _(Context.current).must_equal(c2)
        end
        _(Context.current).must_equal(c1)
      end
    end

    it 'resets context when an exception is raised' do
      c1 = Context.new(nil, 'foo' => 'bar')
      Context.current = c1

      _(proc do
        c2 = Context.current.update('bar', 'baz')
        Context.with_current(c2) do
          raise 'oops'
        end
      end).must_raise(StandardError)

      _(Context.current).must_equal(c1)
    end
  end

  describe '#get' do
    it 'returns corresponding value for key' do
      ctx = Context.new(nil, 'foo' => 'bar')
      _(ctx.get('foo')).must_equal('bar')
    end
  end

  describe '#update' do
    it 'returns new context with entry' do
      c1 = Context.current
      c2 = c1.update('foo', 'bar')
      _(c1.get('foo')).must_be_nil
      _(c2.get('foo')).must_equal('bar')
    end
  end

  describe '#attach' do
    it 'sets context to current' do
      orig_ctx = Context.current
      new_ctx = Context.current.update('foo', 'bar')
      prev_ctx = new_ctx.attach
      _(Context.current).must_equal(new_ctx)
      _(prev_ctx).must_equal(orig_ctx)
    end
  end

  describe '#detach' do
    it 'restores parent context by default' do
      new_ctx = Context.current.update('foo', 'bar')
      prev_ctx = new_ctx.attach
      _(Context.current).must_equal(new_ctx)

      new_ctx.detach
      _(Context.current).must_equal(prev_ctx)
    end

    it 'restores ctx passed in' do
      orig_ctx = Context.current
      ctx1 = orig_ctx.update('foo', 'bar')
      ctx2 = ctx1.update('bar', 'baz')

      ctx1.attach
      prev_ctx = ctx2.attach
      _(Context.current).must_equal(ctx2)

      ctx2.detach(orig_ctx)
      _(Context.current).must_equal(orig_ctx)
      _(Context.current).wont_equal(prev_ctx)
    end

    it 'restores root for ctx without parent' do
      ctx = Context.new(nil, 'foo' => 'bar')
      ctx.detach
      _(Context.current).must_equal(Context::ROOT)
    end
  end
end
