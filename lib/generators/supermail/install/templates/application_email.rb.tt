class ApplicationEmail < Supermail::Base
  def from = "website@example.com"

  def body
     <<~_
     #{yield if block_given?}

     Best,

     The Example.com Team
     _
  end
end
