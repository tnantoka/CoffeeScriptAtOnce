if (!window.csatonce) {
  csatonce = {};
}

csatonce.logs = [];

csatonce.addLog = function(msg) {
  this.logs.push(msg);  
};

csatonce.getLogs = function(separator) {
  return this.logs.join(separator);
};
