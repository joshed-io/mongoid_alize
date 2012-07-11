module MacrosHelper
  def self.included(base)
    base.extend ClassMethods
  end

  module ClassMethods
    def fns
      Mongoid::Alize::Callbacks::From
    end

    def tns
      Mongoid::Alize::Callbacks::To
    end

    def it_should_set_callbacks(klass, inverse_klass, relation, inverse_relation, fns, tns)
      fields = [:fake]

      it "should use #{fns} to pull" do
        obj_mock = MockObject.new
        obj_stub = MockObject.new

        stub(tns).new { obj_stub }
        stub(obj_stub).attach
        stub(inverse_klass)

        mock(fns).new(klass, relation, fields) { obj_mock }
        mock(obj_mock).attach
        klass.send(:alize, relation, *fields)

        klass.alize_callbacks.should == [obj_mock]
      end

      it "should use #{tns} to push" do
        obj_stub = MockObject.new
        obj_mock = MockObject.new

        stub(fns).new { obj_stub }
        stub(obj_stub).attach
        stub(klass).set_callback

        mock(tns).new(inverse_klass, inverse_relation, fields) { obj_mock }
        mock(obj_mock).attach
        klass.send(:alize, relation, *fields)

        inverse_klass.alize_inverse_callbacks.should == [obj_mock]
      end
    end
  end
end
