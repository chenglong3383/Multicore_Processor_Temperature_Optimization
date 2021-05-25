classdef CellImpulse < handle
    % A  CellImpulse object describes the impulse responses from a source node to
    % a target node, it contains:
    % toff          a vector of all the toffs
    % toffInt       an integer id for each toff
    % ton           a vector of all the tons
    % tonInt        an integer id for each ton
    % valid         if this object is valid for use
    % id_s          the id of source node
    % id_t          the id of target node
    % impulse       a vector contains objects of class PeriodSample, each
    %               object describes one impulse response.
    properties (SetAccess = private)
        toff
        ton
        toffInt
        tonInt
        valid
        id_s
        id_t
        impulse
    end
    
    
    methods
        % constructor, 2-D matrix
        function obj        = CellImpulse(varargin)
            obj.valid = false;
            if nargin > 0
                obj(varargin{1}, varargin{2}) = CellImpulse();
            end
            
        end
        
        function []         = ciReset(obj)
            m   = size(obj, 1);
            n   = size(obj, 2);
            for i = 1 : m
                for j = 1 : n
                    if obj(i, j ).valid
                        obj(i, j ).toff        = zeros(1,0);
                        obj(i, j ).ton         = zeros(1,0);
                        obj(i, j ).toffInt     = int64(zeros(1,0));
                        obj(i, j ).tonInt      = int64(zeros(1,0));
                        obj(i, j ).id_s        = 0;
                        obj(i, j ).id_t        = 0;
                        if ~isempty(obj(i, j ).impulse)
                            obj(i, j ).impulse(1:end)= [] ;
                        end
                        obj(i, j ).valid       = false;
                    end
                end
            end
        end
        %%
        function []         = ciInit(obj, id_t, id_s)
            if obj.valid
                error('this object has already been initialized');
            end
            obj.id_s        = id_s;
            obj.id_t        = id_t;
            obj.valid       = true;
        end
        
        function []         = ciAppendToff(obj, toff, ton, impulse)
            if ~obj.valid
                error('object not initialized');
            end
            [flag, toff, ton, toffIntin, tonIntin]          = ciCheckImpulse(obj, toff, ton);
            if flag
                return;
            end
            obj.toff        = [obj.toff, toff];
            obj.ton         = [obj.ton, ton];
            obj.toffInt     = [obj.toffInt, toffIntin];
            obj.tonInt      = [obj.tonInt, tonIntin];
            obj.impulse     = [obj.impulse, impulse];
        end
        
        function [flag, toff, ton, toffIntin, tonIntin, validid] = ciCheckImpulse(obj, toffin, tonin)
            toffIntin = int64(floor(toffin*1e7));
            tonIntin  = int64(floor(tonin*1e7));
            toff    = double(toffIntin)*1e-7;
            ton     = double(tonIntin)*1e-7;
            toffid  = obj.toffInt == toffIntin;
            tonid   = obj.tonInt == tonIntin;
            validid = toffid & tonid;
            flag    = any( toffid & tonid );
        end
        
        function [flag, timps]= ciFindImpulse(obj, toff, ton)
            % toff and ton have the same index!
            [flag, ~, ~, ~, ~, validid]    = ciCheckImpulse(obj, toff, ton);
            if ~flag
                timps = [];
                return
            end
            %             [timps] = intersect( obj.impulse(abs(obj.toff-toff) < 1e-7),...
            %                 obj.impulse(abs(obj.ton-ton) < 1e-7 ));
            [timps] = obj.impulse(validid);
            
        end
        
        function new = ciCopy(obj)
            m   = size(obj, 1);
            n   = size(obj, 2);
            new = CellImpulse(m, n);
            for i = 1 : m
                for j = 1 : n
                    if obj(i, j ).valid
                        prop    = properties(new(i, j));
                        for k = 1 : length(prop)
                            new(i, j).(prop{k}) = obj(i, j).(prop{k});
                        end
                    end
                end
            end
        end

        function n = getImpulseNum(obj)
            n = numel(obj.impulse);
        end
        
    end
    
end


