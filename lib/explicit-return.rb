module ExplicitReturn
	
	def self.included(context)
		context.extend(self)
		context.extend(MethodAddedObserver)
	end

	def explicit(*args)
		ExplicitReturn::ExplicitResult.new(*args)
	end

	def self.explicit(*args)
		ExplicitReturn::ExplicitResult.new(*args)
	end

	module MethodAddedObserver

		def method_added(method_name)
			unless MethodWrapper.busy?
				unbound_method = self.instance_method(method_name)
				obj = self.allocate
				unbound_method.bind(obj)
				MethodWrapper.wrap_method(self, obj.method(method_name), :instance)
			end
		end

		def singleton_method_added(method_name)
			unless MethodWrapper.busy?
				MethodWrapper.wrap_method(self, self.method(method_name), :singleton)
			end
		end

	end

	class ExplicitResult

		attr_accessor :value

		def initialize(value)
			@value = value
		end

	end

	module MethodWrapper

		@@wrapping_method = false

		def self.busy?
			@@wrapping_method
		end

		def self.wrap_method(context, method, type)
			proc = wrap_proc(method.to_proc)
			@@wrapping_method = true
			case type
			when :instance
				context.send(:define_method, method.name, &proc)
			when :singleton 
				context.send(:define_singleton_method, method.name, &proc)
			end
			@@wrapping_method = false
		end

		def self.wrap_proc(proc)
			proc_wrapper = Proc.new{|*args, &block|
				ret = proc.call(*args, &block)
				ret.value if ret.is_a?(ExplicitReturn::ExplicitResult)
			}
		end
	end

end