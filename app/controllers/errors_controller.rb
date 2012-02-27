class ErrorsController < ApplicationController
  def routing
    render_404
  end

  def test
    if current_user.role == 'e9_user'
      raise RuntimeError, "Testing exception (RuntimeError) raised from ErrorsController"
    else
      render_404
    end
  end
end
