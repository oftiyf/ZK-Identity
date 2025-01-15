import { useState } from 'react';
import './demo1.css';
import { processData } from '../../utils/controller.js';

function App() {
  const [hashDisplay, setHashDisplay] = useState('');
  type ProcessResult = {
    solidityInputfinal?: any;  // 根据实际返回值类型调整
    // 添加其他可能的属性
  } | undefined;
  const handleGenerateProof = async () => {
    const getInputValue = (id: string): string => {
      const element = document.getElementById(id) as HTMLInputElement | null;
      if (!element) {
        throw new Error(`Input element ${id} not found`);
      }
      return element.value;
    };

    try {
      const inputs = {
        root: getInputValue('inputRoot'),
        collegeId: getInputValue('collegeId'),
        newNullifier: getInputValue('newnullifier'),
        studentId: getInputValue('studentid'),
        secret: getInputValue('secret'),
        pathElements: getInputValue('pathElements'),
        pathIndices: getInputValue('pathIndices'),
        nullifier: getInputValue('nullifier')
      };
      const result = await processData(inputs) as ProcessResult;
      setHashDisplay(result ? JSON.stringify(result) : 'Proof generated successfully');
    } catch (error) {
      console.error('Error generating proof:', error);
      setHashDisplay('Error generating proof: ' + (error as Error).message);
    }
  };

  return (
    <div className="container">
      <div className="grid"></div>
      <div className="box">
        <div className="clown-emoji">🤡</div>
        <h1 className="title glitch-effect">ZK-Identity</h1>
        
        <div className={`hash-display ${hashDisplay ? 'show' : ''}`}>
          {hashDisplay}
        </div>
        
        <div className="input-columns">
          {/* Left Column: Public Inputs */}
          <div className="input-column">
            <h2 className="subtitle">Public Inputs</h2>
            <div className="content">
              <label>Root:</label>
              <input type="text" className="input-box" id="inputRoot" />
            </div>
            <div className="content">
              <label>College ID:</label>
              <input type="text" className="input-box" id="collegeId" />
            </div>
            <div className="content">
              <label>New Commitment:</label>
              <div style={{ marginLeft: '20px' }}>
                <div className="content">
                  <label>New Nullifier:</label>
                  <input type="text" className="input-box" id="newnullifier" />
                </div>
                <div className="content">
                  <label>Student ID:</label>
                  <input type="text" className="input-box" id="studentid" />
                </div>
              </div>
            </div>
          </div>

          {/* Right Column: Private Inputs */}
          <div className="input-column">
            <h2 className="subtitle">Private Inputs</h2>
            <div className="content">
              <label>Secret:</label>
              <input type="password" className="input-box" id="secret" />
            </div>
            <div className="content">
              <label>Path Elements:</label>
              <input type="text" className="input-box" id="pathElements" />
            </div>
            <div className="content">
              <label>Path Indices:</label>
              <input type="text" className="input-box" id="pathIndices" />
            </div>
            <div className="content">
              <label>Nullifier:</label>
              <input type="text" className="input-box" id="nullifier" />
            </div>
          </div>
        </div>
        
        <button className="submit-btn" onClick={handleGenerateProof}>
          Generate Proof
        </button>
      </div>

      <a href="https://github.com/oftiyf/ZK-Identity/" 
         target="_blank" 
         rel="noopener noreferrer" 
         className="github-icon">
        <svg viewBox="0 0 16 16">
          <path d="M8 0C3.58 0 0 3.58 0 8c0 3.54 2.29 6.53 5.47 7.59.4.07.55-.17.55-.38 0-.19-.01-.82-.01-1.49-2.01.37-2.53-.49-2.69-.94-.09-.23-.48-.94-.82-1.13-.28-.15-.68-.52-.01-.53.63-.01 1.08.58 1.23.82.72 1.21 1.87.87 2.33.66.07-.52.28-.87.51-1.07-1.78-.2-3.64-.89-3.64-3.95 0-.87.31-1.59.82-2.15-.08-.2-.36-1.02.08-2.12 0 0 .67-.21 2.2.82.64-.18 1.32-.27 2-.27.68 0 1.36.09 2 .27 1.53-1.04 2.2-.82 2.2-.82.44 1.1.16 1.92.08 2.12.51.56.82 1.27.82 2.15 0 3.07-1.87 3.75-3.65 3.95.29.25.54.73.54 1.48 0 1.07-.01 1.93-.01 2.2 0 .21.15.46.55.38A8.013 8.013 0 0016 8c0-4.42-3.58-8-8-8z" />
        </svg>
      </a>
      <div id="watchingTexts"></div>
    </div>
  );
}

export default App;