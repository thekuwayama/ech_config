# This file is autogenerated. Do not edit it by hand. Regenerate it with:
#   srb rbi gems

# typed: false
#
# If you would like to make changes to this file, great! Please create the gem's shim here:
#
#   https://github.com/sorbet/sorbet-typed/new/master?filename=lib/ech_config/all/ech_config.rbi
#
# ech_config-0.0.1

class ECHConfig
  def echconfig_contents; end
  def encode(*args, **, &blk); end
  def initialize(version, echconfig_contents); end
  def self.decode_vectors(*args, **, &blk); end
  def self.new(*arg0, **); end
  def version; end
  extend T::Private::Methods::MethodHooks
  extend T::Private::Methods::SingletonMethodHooks
  extend T::Sig
end