
FQTimer = {}

function FQTimer:create(target)
	if target == nil then
		return nil;
	end

	local timer_table = { nodes = {} }
	FQUpdater:register(target, timer_table)

	function timer_table:update()
		for i=1, #(self.nodes), 1 do
			local node = self.nodes[i];
			node:_update();
			if self.nodes == nil or #(self.nodes) <= 0 then
				return
			end
		end
	end

	function timer_table:clean()
		self.nodes = {}
	end

	function timer_table:add_empty_timer()
		local ticker = self:add_timer(0, 0, nil, nil)
		ticker:reset()
		return ticker
	end

	function timer_table:add_timer(interval, times, callback)
		if interval == nil then
			interval = 1000
		end
		if times == nil then
			times = 1
		end

		local timer_node = {}
		timer_node.interval = 0;
	    timer_node.expendTime = 0;
	    timer_node.startRunTime = 0
	    timer_node.times = 0;
	    timer_node.count = 0;
	    timer_node.callback = nil;
	    timer_node.running = false;
	    timer_node.called = false;

		function timer_node:set_timer(interval, times, callback)
			self.interval = interval / 1000;
			self.startRunTime = FQUtils:get_time()
	        self.expendTime = 0;
	        self.times = times;
	        self.count = 0;
	        self.callback = callback;
	        self.running = true;
	        self.called = false;
		end

		function timer_node:reset()
			self.interval = 0;
	        self.expendTime = 0;
	        self.times = 0;
	        self.count = 0;
	        self.callback = nil;
	        self.running = false;
	        self.called = false;
		end

		function timer_node:get_count()
	        return self.count;
		end

		function timer_node:_update()
			if self.running == false then
				return;
			end

			local current_time = FQUtils:get_time()
	        self.expendTime = current_time - self.startRunTime

	        if self.expendTime >= self.interval then
	        	self.startRunTime = current_time;
	            self.expendTime = 0;
	            self.called = true;
	            self.count = self.count + 1;

	            if self.callback ~= nil then
	                self.callback(self);
	            end

	            if self.called == true then
	                if self.count == self.times then
	                    self:reset();
					end
	            end
	        end
		end
		timer_node:set_timer(interval, times, callback);
		table.insert(self.nodes, timer_node);
		return timer_node;
	end

	return timer_table;
end